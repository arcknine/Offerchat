class Visitor < ActiveRecord::Base
  attr_accessible :token , :browser, :ipaddress, :location

  belongs_to :website
  has_many :chat_sessions

  before_create :generate_token

  def generate_token
    self.token = loop do
      random_token = SecureRandom.urlsafe_base64(nil, false)
      break random_token unless Visitor.where(token: random_token).exists?
    end
  end


end
