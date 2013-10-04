class QuickResponse < ActiveRecord::Base
  attr_accessible :message, :shortcut

  validates_presence_of :message, :shortcut

  belongs_to :website
  belongs_to :user
end
