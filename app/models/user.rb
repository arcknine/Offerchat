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

  def group(owner_id)
    owner = User.find(owner_id)
    accs  = self.accounts.collect(&:website_id)
    sites = owner.websites
    arr   = []
    sites.each do |s|
      arr.push("#{s.url} (Agent)") if accs.include? s.id
    end
    arr.join(", ")
  end

  def small_avatar
    avatar.url(:small)
  end

  def account(website_id)
    accounts.where("website_id = ?", website_id).first
  end

  def my_agents
    owner_websites = self.websites.collect(&:id).join(",")
    owner_accounts = Account.joins("LEFT JOIN websites ON websites.id = accounts.website_id").where("website_id IN (?) AND role != ?", owner_websites, Account::OWNER)
    owner_accounts.collect(&:user)
  end

  def agents
    owner_websites = self.websites.collect(&:id).join(",")
    owner_accounts = Account.joins("LEFT JOIN websites ON websites.id = accounts.website_id").where("website_id IN (?)", owner_websites)
    owner_accounts.collect(&:user)
  end

  def find_managed_sites(website_id)
    site = self.accounts.keep_if do |e|
      (e.role == Account::OWNER || e.role == Account::ADMIN) && (e.website_id == website_id.to_i)
    end
    site.try(:first).try(:website)
  end

  def admin_sites
    accounts.where("role = ? OR role = ?", Account::ADMIN, Account::OWNER).collect(&:website)
  end

  def all_sites
    accounts.collect(&:website)
  end

  def self.create_or_invite_agents(user, account_array)
    user = User.find_or_initialize_by_email(user[:email])
    user_is_new = false

    if owner.seats_available <= 0
      raise Exceptions::AgentLimitReachedError
    end

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
      unless p[:website_id].blank? && p[:website_id].nil?
        role            = p[:is_admin] ? Account::ADMIN : Account::AGENT
        account         = Account.new(:role => role)
        account.user    = user
        account.website = Website.find(p[:website_id])
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
      unless p[:website_id].blank? && p[:website_id].nil?
        account      = Account.find(p[:account_id])
        account.role = p[:is_admin] ? Account::ADMIN : Account::AGENT
        account.save
        has_checked_website = true
      end
    end

    user = User.find(id)
    user.errors[:base] << "No website is checked" unless has_checked_website

    user
  end

  def self.migration_agents(owner, user, account_array)
    user = User.find_or_initialize_by_email(user[:email])
    user_is_new = false

    if user.new_record?
      password                   = Devise.friendly_token[0,8]
      user.password              = password
      user.password_confirmation = password
      user.name                  = user[:name] || user.email.split('@').first
      user.display_name          = "Support"
      user.save
      user_is_new = true
    end

    has_checked_website = false
    account_array.each do |p|
      unless p[:website_id].blank? && p[:website_id].nil?
        unless p[:role] == 0
          role            = p[:is_admin] ? Account::ADMIN : Account::AGENT
          account         = Account.new(:role => role)
          account.user    = user
          account.owner   = owner
          account.website = Website.find(p[:website_id])
          account.save

          has_checked_website = true

          if user_is_new
            UserMailer.delay.new_agent_welcome(account, user, password) unless user.errors.any?
          else
            UserMailer.delay.old_agent_welcome(account, user) unless user.errors.any?
          end
        end
      end
    end unless user[:email].empty?

    user.errors[:base] << "Please provide an email for that agent." if user[:email].empty?
    user.errors[:base] << "Agent must be assigned to at least 1 site." unless has_checked_website
    user
  end

  def self.update_roles_and_websites(id, owner, account_array)
    # websites = current_user.accounts.where("role != ?", Account::AGENT).collect(&:website_id).join(",")
    # user.accounts.where("website_id IN (?)", websites).delete_all

    has_checked_website = false
    account_array.each do |p|
      unless p[:website_id].blank? && p[:website_id].nil?
        unless p[:account_id].nil?
          account      = Account.find(p[:account_id])
          unless p[:role] == 0
            account.role = p[:is_admin] ? Account::ADMIN : Account::AGENT
            account.save
            has_checked_website = true
          else
            account.destroy
          end
        else
          account         = Account.new(:role => p[:role])
          account.user    = User.find(id)
          account.owner   = owner
          account.website = Website.find(p[:website_id])
          account.save
          has_checked_website = true
        end
      end
    end
    User.find(id)
  end

  def my_agents_emails
    Account.select("DISTINCT users.email").joins("LEFT JOIN users ON users.id=accounts.owner_id").where("accounts.owner_id=?", self.id).collect{|data| data.email}.join ", "
  end

  def self.migration_agents(owner, user, account_array)
    user = User.find_or_initialize_by_email(user[:email])
    user_is_new = false

    if user.new_record?
      password                   = Devise.friendly_token[0,8]
      user.password              = password
      user.password_confirmation = password
      user.name                  = user[:name] || user.email.split('@').first
      user.display_name          = "Support"
      user.save
      user_is_new = true
    end

    has_checked_website = false
    account_array.each do |p|
      unless p[:website_id].blank? && p[:website_id].nil?
        unless p[:role] == 0
          role            = p[:is_admin] ? Account::ADMIN : Account::AGENT
          account         = Account.new(:role => role)
          account.user    = user
          account.owner   = owner
          account.website = Website.find(p[:website_id])
          account.save

          has_checked_website = true

          if user_is_new
            UserMailer.delay.new_agent_welcome(account, user, password) unless user.errors.any?
          else
            UserMailer.delay.old_agent_welcome(account, user) unless user.errors.any?
          end
        end
      end
    end unless user[:email].empty?
    # user.errors[:base] << "Please provide an email for that agent." if user[:email].empty?
    # user.errors[:base] << "Agent must be assigned to at least 1 site." unless has_checked_website


  end

  private

  def create_jabber_account
    self.update_attributes(:jabber_user => "#{self.id}#{self.created_at.to_i}", :jabber_password => SecureRandom.hex(8))
    # Create the account on Openfire
    JabberUserWorker.perform_async(self.id)
  end
end
