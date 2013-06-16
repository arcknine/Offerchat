class Account < ActiveRecord::Base
  attr_accessible :role

  OWNER = 1
  ADMIN = 2
  AGENT = 3

  belongs_to :user
  belongs_to :website
end
