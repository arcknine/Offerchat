class Account < ActiveRecord::Base
  attr_accessible :owner_id, :role, :website_id, :user_id

  belongs_to :user
end
