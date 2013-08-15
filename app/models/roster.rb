class Roster < ActiveRecord::Base
  attr_accessible :jabber_password, :jabber_user, :website_id, :last_used
  belongs_to :website
  has_many :chat_sessions

  validates_presence_of :jabber_user
  validates_presence_of :jabber_password
  validates :jabber_user, :uniqueness => true
end
