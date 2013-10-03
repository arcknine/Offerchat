require 'spec_helper'

describe ReportsController do

  context "when not login" do
    it "'ratings' should not be acceptable" do
      xhr :get, :index, format: :json
      response.code.should eq "401"
    end
  end

  context "when login" do
    login_user

    describe "when current user has no website" do
      it "'ratings' is not viewable" do
        xhr :get, :index, format: :json
        response.code.should eq "401"
      end
    end

    describe "current user has website" do
      generate_website

      it "GET 'index' should return ratings" do
        xhr :post, :index, format: :json
        response.code.should eq "200"
      end

      it "GET 'ratings' should return ratings" do
        xhr :post, :ratings, website_id: [@website.id], user_id: [@user.id], format: :json
        response.code.should eq "200"
        assigns(:ratings).should_not be_nil
      end

      it "GET 'index' should return ratings" do
        xhr :post, :stats, website_id: [@website.id], user_id: [@user.id], format: :json
        response.code.should eq "200"
        assigns(:stats).should_not be_nil
      end
    end
  end
end
