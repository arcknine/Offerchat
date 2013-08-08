class StripeMessage < ActiveRecord::Base
  attr_accessible :event_id, :created, :livemode, :type, :data, :previous_attributes

  def data_to_json
    JSON.parse data
  end

  def previous_attributes_to_json
    JSON.parse previous_attributes
  end
end
