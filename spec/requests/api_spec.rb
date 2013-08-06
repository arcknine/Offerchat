require 'spec_helper'

describe Offerchat::API do
  before(:each) do
    @website = Fabricate(:website, :owner => Fabricate(:user))
  end
  describe "GET token" do
    it "returns a json token" do
      get "/api/v1/widget/token/#{@website.api_key}"
      response.status.should == 200
    end
  end

  describe "GET position" do
    it "returns a position of the widget" do
      get "/api/v1/widget/position/#{@website.api_key}"
      response.status.should == 200
    end
  end

  describe "GET settings" do
    it "returns an array of settings" do
      get "/api/v1/widget/position/#{@website.api_key}"
      response.status.should == 200
    end
  end

  describe "GET any_agents_online" do
    it "returns bolean if there is agent online" do
      get "/api/v1/widget/any_agents_online/#{@website.api_key}"
      response.status.should == 200
    end
  end


end