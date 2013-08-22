require 'spec_helper'

describe Dashmigrate::API do

  describe "GET users data" do
    it "returns a json token" do
      get "/api/v1/migration/user"
      response.status.should == 200
    end
  end
end
