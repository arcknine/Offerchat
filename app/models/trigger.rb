class Trigger < ActiveRecord::Base
  belongs_to :website
  attr_accessible :message, :rule_type, :status, :website_id, :params
  serialize :params

  validates_presence_of :message
  validates_presence_of :rule_type
  validates_presence_of :params

  before_save :set_defaults

  def set_defaults
    self.status = 1
  end
end
