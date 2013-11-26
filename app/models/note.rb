class Note < ActiveRecord::Base
  belongs_to :visitor
  belongs_to :user
  attr_accessible :message, :visitor_id, :user_id

  def user_info
    User.find(self.user_id)
  end

end
