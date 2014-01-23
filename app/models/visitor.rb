class Visitor < ActiveRecord::Base
  attr_accessible :token , :browser, :ipaddress, :location, :name, :email, :operating_system, :country_code, :phone

  belongs_to :website
  has_many :chat_sessions
  has_many :notes
end
