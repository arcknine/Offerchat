class Website < ActiveRecord::Base
  attr_accessible :api_key, :name, :url, :owner

  before_create :generate_api_key
  after_create :generate_account
  after_create :generate_rosters
  before_validation :generate_website_name
  after_destroy :delete_accounts

  has_many :accounts
  has_many :rosters
  has_many :triggers
  belongs_to :owner, :foreign_key => "owner_id", :class_name => "User"

  validates_presence_of :url
  validates_presence_of :name
  validates :url, :format => /^(http(s?):\/\/)?(www\.)+[a-zA-Z0-9\.\-\_]+(\.[a-zA-Z]{2,3})+(\/[a-zA-Z0-9\_\-\s\.\/\?\%\#\&\=]*)?$/

  has_settings do |s|
    s.key :style, :defaults => { :theme => "greengrass", :position => "right", :rounded => false, :gradient => false }
    s.key :online, :defaults => { :header => "Chat with us", :agent_label => "Got a question? We can help.", :greeting => "Hi, I am", :placeholder => "Type your message and hit enter" }
    s.key :pre_chat, :defaults => { :enabled => false, :message_required => false, :header => "Let me get to know you!", :description => "Fill out the form to start the chat." }
    s.key :post_chat, :defaults => { :enabled => true, :header => "Chat with me, I'm here to help", :description => "Please take a moment to rate this chat session", :email => "" }
    s.key :offline, :defaults => { :enabled => true,  :header => "Contact Us", :description => "Leave a message and we will get back to you ASAP.", :email => "" }
  end

  # scope :as, ->(role) do
  #   joins(:accounts).where('role = ?', role)
  # end

  def generate_visitor_id
    "visitor_#{id}_#{(0..9).to_a.shuffle[0,6].join}"
  end

  def agents
    accounts = Account.joins("LEFT JOIN websites ON websites.id = accounts.website_id").where("website_id = ? AND role != ?", self.id, Account::OWNER)
    accounts.collect(&:user)
  end

  def owner_and_agents
    accounts = Account.joins("LEFT JOIN websites ON websites.id = accounts.website_id").where("website_id = ?", self.id)
    accounts.collect(&:user)
  end

  def unread; 0; end

  def style
    settings.style
  end


  def save_settings(params)
    components = params.keys
    components.each do |c|
      attributes = params[c].keys
      attributes.each do |a|
        self.settings(c.to_sym).send("#{a}=", params[c][a])
      end
    end

    self.save
  end


  private

  def generate_api_key
    begin
      self.api_key = SecureRandom.hex
    end while self.class.exists?(api_key: api_key)
  end

  def generate_account
    account = self.accounts.build
    account.user = self.owner
    account.role = Account::OWNER
    account.save
  end

  def generate_rosters
    GenerateRostersWorker.perform_async(self.id)
  end


  def delete_accounts
    accounts.destroy_all
  end

  def generate_website_name
    if name.blank?
      name = url.to_s.gsub('.', ' ')
    end
  end

end
