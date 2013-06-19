class Roster < ActiveRecord::Base
  attr_accessible :jabber_password, :jabber_user, :website_id

  belongs_to :website

  validates_presence_of :jabber_user
  validates_presence_of :jabber_password
  validates :jabber_user, :uniqueness => true
end
