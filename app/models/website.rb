class Website < ActiveRecord::Base
  attr_accessible :api_key, :name, :url, :owner

  before_create :generate_api_key
  after_create :generate_account
  after_create :generate_rosters

  has_many :accounts
  has_many :rosters
  belongs_to :owner, :foreign_key => "owner_id", :class_name => "User"

  validates_presence_of :url
  validates :url, :format => /^(http(s?):\/\/)?(www\.)+[a-zA-Z0-9\.\-\_]+(\.[a-zA-Z]{2,3})+(\/[a-zA-Z0-9\_\-\s\.\/\?\%\#\&\=]*)?$/

  has_settings do |s|
    s.key :style, :defaults => { :theme => "greengrass", :position => "right", :rounded => false, :gradient => false }
    s.key :online, :defaults => { :header => "Chat with us", :agent_label => "Got a question? We can help.", :greeting => "Hi, I am", :placeholder => "Type your message and hit enter" }
    s.key :pre_chat, :defaults => { :enabled => false, :message_required => false, :header => "Let me get to know you!", :description => "Fill out the form to start the chat." }
    s.key :post_chat, :defaults => { :enabled => true, :header => "Chat with me, I'm here to help", :description => "Please take a moment to rate this chat session" }
    s.key :offline, :defaults => { :enabled => true,  :header => "Contact Us", :description => "Leave a message and we will get back to you ASAP." }
  end

  def create_and_subscribe_rosters
    (1..30).each do |i|
      uniqueid = (0..9).to_a.shuffle[0,6].join
      visitor  = "visitor_#{id}_#{uniqueid}"

      password = (0..16).to_a.map{|a| rand(16).to_s(16)}.join
      roster   = Roster.create(:jabber_user => visitor, :jabber_password => password, :website_id => id)

      sleep(5)
      OpenfireApi.create_user(roster.jabber_user, roster.jabber_password)
      sleep(5)
      OpenfireApi.subcribe_roster(owner.jabber_user, visitor, name, url)
      sleep(5)
      OpenfireApi.subcribe_roster(visitor, owner.jabber_user, name, url)
    end
  end

  def generate_visitor_id
    "visitor_#{id}_#{(0..9).to_a.shuffle[0,6].join}"
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
end
