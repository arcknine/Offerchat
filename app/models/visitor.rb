class Visitor < ActiveRecord::Base
  attr_accessible :token , :browser, :ipaddress, :location, :name, :email, :operating_system, :country_code, :phone

  belongs_to :website
  has_many :chat_sessions
  has_many :notes

  before_create :generate_token
  before_create :generate_name
  after_create  :activate_funnel

  include Vero::DSL

  def generate_token
    self.token = loop do
      random_token = SecureRandom.urlsafe_base64(nil, false)
      break random_token unless Visitor.where(token: random_token).exists?
    end
  end

  def generate_name
    if self.name.nil?
      self.name = 'visitor-%06d' % rand(6 ** 6)
    end
  end

  def activate_funnel
    if website.visitors.count <= 1
      MIXPANEL.track "Install Widget", { :distinct_id => website.owner.email }
      vero.events.track!({ :event_name => "Install Widget", :identity => { :email => website.owner.email } })
      website.owner.update_attribute(:widget_installed, true)
    end
  end
end
