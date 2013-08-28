require 'spec_helper'

describe VisitorsController do
  context "when not login" do
  	before(:each) do
  		@visitor = Fabricate(:visitor)
  	end
    it "'index' should not be acceptable" do
      xhr :get, :show, id: @visitor.id ,format: :json
      response.code.should eq "401"
    end
  end

  context "when login" do
    login_user

    describe "when the visitor exists" do
    	before(:each) do
	  		@visitor = Fabricate(:visitor)
	  	end
      it "GET 'show' should be viewable" do
        xhr :get, :show, id: @visitor.id, format: :json
        response.code.should eq "200"
      end
      xit "GET 'show' should throw an error if the visitor does not exist" do
        xhr :get, :show, id: @visitor.id, format: :json
        response.code.should eq "200"
      end
    end
  end
end
