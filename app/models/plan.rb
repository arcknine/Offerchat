class Plan < ActiveRecord::Base
  attr_accessible :description, :max_agent_seats, :name, :price, :features, :plan_identifier
  serialize :features, Array
end
