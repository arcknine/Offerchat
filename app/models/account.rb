class Account < ActiveRecord::Base
  attr_accessible :role, :website_id, :user_id

  OWNER = 1
  ADMIN = 2
  AGENT = 3

  belongs_to :user
  belongs_to :website
  # belongs_to :owner, :foreign_key => "owner_id", :class_name => "User"
end
