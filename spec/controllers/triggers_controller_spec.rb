require 'spec_helper'

describe TriggersController do

  context "when not login" do
    it "'index' should not be acceptable" do
      xhr :get, :index, format: :json
      response.code.should eq "401"
    end
  end

  context "when login" do
    login_user

    describe "when no website id is supplied" do
      it "'index' is not viewable" do
        xhr :get, :index, format: :json
        response.code.should eq "401"
      end
    end

    describe "when website id is supplied" do
      it "'index' returns list of triggers" do
        @website = Fabricate(:website)
        @triggers = Fabricate(:trigger, :website => @website)
        xhr :get, :index, website_id: @website.id, format: :json
        response.code.should eq "200"
      end
    end

    describe "when website has triggers" do
      generate_website

      it "DELETE 'destroy' should remove 1 trigger" do
        @trigger = Fabricate(:trigger)
        xhr :delete, :destroy, id: @trigger.id, format: :json
        Trigger.all.count.should eq(1)
      end

      it "GET 'index' should have triggers" do
        @website = Fabricate(:website)
        @triggers = Fabricate(:trigger, :website => @website)
        xhr :get, :index, website_id: @website.id, format: :json
        assigns(:triggers).should_not be_nil
      end

      let(:valid_put) do
        {
          "rule_type"  => 3,
          "message" => "My Test Trigger Message"
        }
      end

      let(:invalid_put) do
        {
          "rule_type"  => "",
        }
      end

      def do_update(type = "valid")
        if type == "valid"
          xhr :put, :update, id: @trigger.id, trigger: valid_put, format: :json
        else
          xhr :put, :update, id: @trigger.id, trigger: invalid_put, format: :json
        end
      end

      it "PUT 'update' should have trigger" do
        do_update
        assigns(:trigger).should_not be_nil
        assigns(:trigger).message.should_not be_nil
      end

      it "PUT 'update' should be able to update trigger" do
        do_update
        assigns(:trigger).rule_type.should eq 3
        assigns(:trigger).message.should eq("My Test Trigger Message")
      end

      it "PUT 'update' should not accept invalid data" do
        do_update("invalid")

        JSON.parse(response.body)["errors"].should_not be_blank
        response.code.should eq "422"
      end

      def do_destroy
        @trig = Fabricate(:trigger)
        xhr :delete, :destroy, id: @trig.id, format: :json
      end

      it "DELETE 'destroy' should remove 1 trigger" do
        do_destroy
        Trigger.all.count.should eq(1)
      end

      it "DELETE 'destroy' should return json" do
        do_destroy
        response.code.should eq "204"
      end

    end
  end

end