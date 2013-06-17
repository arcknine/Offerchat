class Website < ActiveRecord::Base
  attr_accessible :api_key, :name, :settings, :url

  validates_presence_of :url
  validates :url, :format => URI::regexp(%w(http https))
end
