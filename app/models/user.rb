class User < ActiveRecord::Base
  require 'securerandom'

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable


  has_many :accounts
  has_many :websites, :foreign_key => "owner_id"

  attr_accessible :email, :password, :password_confirmation, :remember_me,
    :name, :display_name, :jabber_user, :jabber_password, :avatar

  validates_presence_of :name
  validates_presence_of :display_name
  validates_length_of :name, :in => 4..50

  after_create :create_jabber_account

  has_attached_file :avatar,
    :storage => :s3,
    :bucket => Rails.env.production? ? 'offerchat' : 'offerchat-staging',
    :s3_credentials => {
      :access_key_id => 'AKIAI4KRAOR4GE6GES7Q',
      :secret_access_key => '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'
    },
    :styles => { :small => "55x55>", :thumb => "40x40>" },
    :default_url => '/assets/avatar.jpg'

  validates_attachment_content_type :avatar, :content_type => [ "image/jpg", "image/jpeg", "image/png" ], :message => "Only image files are allowed."
  validates :email, :format => { :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i }

  def account(website_id)
    accounts.where("website_id = ?", website_id).first
  end

  def pending?
    created_at == updated_at
  end

  def my_agents
    owner_websites = self.websites.collect(&:id).join(",")
    owner_accounts = Account.joins("LEFT JOIN websites ON websites.id = accounts.website_id").where("website_id IN (?) AND role != ?", owner_websites, Account::OWNER)
    owner_accounts.collect(&:user)
  end

  def self.create_or_invite_agents(user, account_array)
    user = User.find_or_initialize_by_email(user[:email])

    if user.new_record?
      password                   = Devise.friendly_token[0,8]
      user.password              = password
      user.password_confirmation = password
      user.name                  = user.email.split('@').first
      user.display_name          = "Support"
      user.save
    end

    has_checked_website = false
    account_array.each do |p|
      unless p['website_id'].blank? && p['website_id'].nil?
        role            = p["is_admin"] ? Account::ADMIN : Account::AGENT
        account         = Account.new(:role => role)
        account.user    = user
        account.website = Website.find(p['website_id'])
        account.save

        has_checked_website = true
      end
    end

    user.errors[:base] << "No website is checked" unless has_checked_website
    UserMailer.delay.agent_welcome(user.accounts.last.website.owner, user) unless user.errors.any?

    user
  end

  def self.update_roles_and_websites(id, account_array)
    # websites = current_user.accounts.where("role != ?", Account::AGENT).collect(&:website_id).join(",")
    # user.accounts.where("website_id IN (?)", websites).delete_all

    has_checked_website = false
    account_array.each do |p|
      unless p['website_id'].blank? && p['website_id'].nil?
        account      = Account.find(p['account_id'])
        account.role = p["is_admin"] ? Account::ADMIN : Account::AGENT
        account.save

        has_checked_website = true
      end
    end

    user = User.find(id)
    user.errors[:base] << "No website is checked" unless has_checked_website

    user
  end

  private

  def create_jabber_account
    self.update_attributes(:jabber_user => "#{self.id}#{self.created_at.to_i}", :jabber_password => SecureRandom.hex(8))
    # Create the account on Openfire
    JabberUserWorker.perform_async(self.id)
  end
end
