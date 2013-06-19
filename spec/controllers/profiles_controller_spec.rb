require 'spec_helper'

describe ProfilesController do
  
  context "when i'm not signed in" do
    describe "GET 'account'" do
      it "should not be acceptable" do
        xhr :get, :show, format: :json
        response.code.should eq "401"
      end
    end
  end

  
  context "when user is signed in" do
    login_user

    let(:valid_put) do
      {
        "avatar" => File.new(Rails.root + 'spec/support/images/avatar.png')
      }
    end
    
    describe "GET 'account'" do
      it "should be acceptable" do
        xhr :get, :show, format: :json
        response.code.should eq "200"
        assigns(:profile).should_not be_nil
      end
    end
    
    describe "UPDATE 'account'" do
      it "should be able to update avatar" do
        xhr :put, :update, id: @user.id, profile: valid_put, format: :json
        assigns(:profile).avatar.instance_read(:file_name).should eq File.basename(File.new(Rails.root + 'spec/support/images/avatar.png')).downcase
      end
    end
  end
end
