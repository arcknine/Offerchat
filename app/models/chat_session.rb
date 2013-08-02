class ChatSession < ActiveRecord::Base
  # attr_accessible :title, :body

  belongs_to :visitor
end
