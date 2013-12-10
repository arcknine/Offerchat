require 'spec_helper'

describe QuickResponsesController do
  context "when not login" do
    it "'index' should not be acceptable" do
      xhr :get, :index, format: :json
      response.code.should eq "401"
    end
  end

  context "when login" do
    login_user

    before(:each) do
      @qr = Fabricate(:quick_response)
    end

    let(:valid_put) do
      {
        "shortcut"  => "/hello",
        "message" => "My Test QR"
      }
    end
    let(:missing_message) do
      {
        "shortcut" => "/hello"
      }
    end
    let(:missing_shortcut) do
      {
        "message" => "hello"
      }
    end
    let(:invalid_shortcut) do
      {
        "shortcut" => "hello",
        "message" => "hello"
      }
    end

    def do_update(type = "valid")
      if type == "valid"
        xhr :put, :update, id: @qr.id, quick_response: valid_put, format: :json
      else
        xhr :put, :update, id: @qr.id, quick_response: type, format: :json
      end
    end

    def do_create(type = "valid")
      if type == "valid"
        xhr :post, :create, quick_response: valid_put, format: :json
      else
        xhr :post, :create, quick_response: type, format: :json
      end
    end

    describe "valid input" do
      it "update should return success" do
        do_update
        response.code.should eq "200"
      end

      it "create should return success" do
        do_create
        response.code.should eq "200"
      end
    end

    describe "invalid input" do
      it "'UPDATE missing shortcut' should generate error" do
        do_update missing_shortcut
        response.code.should eq "401"
      end
      it "'UPDATE missing message' should generate error" do
        do_update missing_message
        response.code.should eq "401"
      end
      it "'UPDATE invalid shortcut' should generate error" do
        do_update invalid_shortcut
        response.code.should eq "401"
      end

      it "'CREATE missing shortcut' should generate error" do
        do_create missing_shortcut
        response.code.should eq "401"
      end
      it "'CREATE missing message' should generate error" do
        do_create missing_message
        response.code.should eq "401"
      end
      it "'CREATE invalid shortcut' should generate error" do
        do_create invalid_shortcut
        response.code.should eq "401"
      end
    end

  end

end
