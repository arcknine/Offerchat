class QuickResponse < ActiveRecord::Base
  attr_accessible :message, :shortcut, :website_id

  validates_presence_of :message, :shortcut

  belongs_to :website
end
