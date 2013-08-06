class ChatSession < ActiveRecord::Base
  attr_accessible :visitor_id, :roster_id

  belongs_to :visitor
  belongs_to :roster
end
