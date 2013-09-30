class Rating < ActiveRecord::Base
  belongs_to :user
  belongs_to :website

  attr_accessible :down, :up, :token, :user, :website
end
