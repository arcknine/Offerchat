require 'spec_helper'

describe VisitorNotesController do

  context "when not login" do
    it "'index' should not be acceptable" do
      xhr :get, :index, format: :json
      response.code.should eq "401"
    end
  end

  context "when login" do
    login_user

    before(:each) do
      @user = Fabricate(:starter_user)
      @visitor = Fabricate(:visitor)
    end

    describe "POST 'create'" do
      it "should have visitor name" do
        xhr :post, :create, message: "This is a test message", vtoken: @visitor.token
        Note.all.count.should eq(1)
      end
    end
  end



end
