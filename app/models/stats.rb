class Stats < ActiveRecord::Base
  attr_accessible :active, :missed, :proactive

  belongs_to :user
  belongs_to :website
end
