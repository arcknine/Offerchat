class User < ActiveRecord::Base
  require 'securerandom'

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable


  has_many :accounts
  has_many :websites, :foreign_key => "owner_id"

  attr_accessible :email, :password, :password_confirmation, :remember_me,
    :name, :display_name, :jabber_user, :jabber_password, :avatar

  validates_presence_of :name
  validates_length_of :name, :in => 4..15

  after_create :create_jabber_account

  has_attached_file :avatar,
    :storage => :s3,
    :bucket => Rails.env.production? ? 'offerchat' : 'offerchat-staging',
    :s3_credentials => {
      :access_key_id => 'AKIAI4KRAOR4GE6GES7Q',
      :secret_access_key => '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'
    },
    :styles => { :small => "55x55>", :thumb => "40x40>" }

  validates_attachment_content_type :avatar, :content_type => [ "image/jpg", "image/jpeg", "image/png" ], :message => "Only image files are allowed."
  validates :email, :format => { :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i, :on => :create }

  def account(website_id)
    accounts.where("website_id = ?", website_id).first
  end

  def pending?
    created_at == updated_at
  end

  def my_agents
    websites = self.websites.collect(&:id).join(",")
    accounts = Account.joins("LEFT JOIN websites ON websites.id = accounts.website_id").where("website_id IN (?) AND role != ?", websites, Account::OWNER)
    accounts.collect(&:user)
  end

  def self.create_or_invite_agents(user, arr)
    user = User.find_or_initialize_by_email(user[:email])
    password = Devise.friendly_token[0,8]

    if user.new_record?
      user.password = password
      user.password_confirmation = password
      user.name = user.email.split('@').first
      user.display_name = "Support"
    end

    if user.save
      arr.each do |p|
        account = Account.new(:role => p[:role])
        account.user = user
        account.website = Website.find(p['website_id'])
        account.save

        UserMailer.delay.agent_welcome(account.website.owner, user)
      end
    end

    user
  end

  private

  def create_jabber_account
    self.update_attributes(:jabber_user => "#{self.id}#{self.created_at.to_i}", :jabber_password => SecureRandom.hex(8))
    # Create the account on Openfire
    JabberUserWorker.perform_async(self.id)
  end
end
