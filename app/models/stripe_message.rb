class StripeMessage < ActiveRecord::Base
  attr_accessible :response

  def json_response
    JSON.parse response
  end
end
