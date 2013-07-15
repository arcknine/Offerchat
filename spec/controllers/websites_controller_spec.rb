require 'spec_helper'

describe WebsitesController do
  context "when not login" do
    it "'index' should not be acceptable" do
      xhr :get, :index, format: :json
      response.code.should eq "401"
    end
  end

  context "when login" do
    login_user

    describe "when current user has no website" do
      it "'index' is not viewable" do
        xhr :get, :index, format: :json
        response.code.should eq "401"
      end
    end

    describe "current user has website" do
      generate_website

      let(:valid_put) do
        {
          "url"  => "http://www.mytestsite.com",
          "name" => "My Test Site Inc."
        }
      end

      let(:invalid_put) do
        {
          "url"  => "not a valid url",
        }
      end

      it "GET 'index' should be viewable" do
        xhr :get, :index, format: :json
        response.code.should eq "200"
      end

      it "GET 'index' should have websites" do
        xhr :get, :index, format: :json
        assigns(:websites).should_not be_nil
      end

      def do_update(type = "valid")
        if type == "valid"
          xhr :put, :update, id: @website.id, website: valid_put, format: :json
        else
          xhr :put, :update, id: @website.id, website: invalid_put, format: :json
        end
      end

      it "PUT 'update' should have website" do
        do_update
        assigns(:website).should_not be_nil

        assigns(:website).api_key.should_not be_nil
        assigns(:website).name.should_not be_nil
        assigns(:website).url.should_not be_nil
        assigns(:website).owner.should_not be_nil
      end

      it "PUT 'update' should be able to update website" do
        do_update
        assigns(:website).url.should eq("http://www.mytestsite.com")
        assigns(:website).name.should eq("My Test Site Inc.")
      end

      it "PUT 'update' should not accept invalid data" do
        do_update("invalid")

        JSON.parse(response.body)["errors"].should_not be_blank
        response.code.should eq "422"
      end

      def do_destroy
        xhr :delete, :destroy, id: @website.id, format: :json
      end

      it "DELETE 'destroy' should remove 1 agent" do
        expect {
          do_destroy
        }.to change(Website, :count).to(0)
      end

      it "DELETE 'destroy' should return json" do
        do_destroy
        response.code.should eq "204"
      end
    end
  end
end
