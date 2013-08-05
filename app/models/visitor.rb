class Visitor < ActiveRecord::Base
  attr_accessible :token , :browser, :ipaddress, :location, :name, :email

  belongs_to :website
  has_many :chat_sessions

  before_create :generate_token
  before_create :generate_name

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


end
