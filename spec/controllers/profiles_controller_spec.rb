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
        "email" => "mksgamon@yahoo.com",
        "display_name" => "Mark Gamzy Display Name",
        "name" => "Mark Gamzy"
      }
    end

    let(:invalid_put) do
      {"email" => "mksgamon"}
    end

    describe "GET 'account'" do
      it "should be acceptable" do
        xhr :get, :show, format: :json
        response.code.should eq "200"
        assigns(:profile).should_not be_nil
      end
    end

    describe "UPDATE 'account'" do
      it "should be able to update profile" do
        xhr :put, :update, id: @user.id, profile: valid_put, format: :json
        assigns(:profile).email.should eq "mksgamon@yahoo.com"
        assigns(:profile).display_name.should eq "Mark Gamzy Display Name"
        assigns(:profile).name.should eq "Mark Gamzy"
      end

      it "should not accept invalid data" do
        xhr :put, :update, id: @user.id, profile: invalid_put, format: :json
        JSON.parse(response.body)["errors"].should_not be_blank
        response.code.should eq "422"
      end

      it "should remove avatar if avatar value is 'remove'" do
        xhr :put, :update, id: @user.id, profile: {avatar_remove: true}, format: :json
        assigns(:profile).avatar.to_s.should eq "http://s3.amazonaws.com/offerchat/users/avatars/avatar.jpg"
        response.code.should eq "200"
      end
    end

    describe "uploading avatars" do
      it "should be able to update avatar" do
        post :update_avatar, :avatar => fixture_file_upload('/avatar/avatar.jpg')
        assigns(:profile).avatar.to_s.should_not eq "http://s3.amazonaws.com/offerchat/users/avatars/avatar.jpg"
        response.code.should eq "200"
      end

      it "should not accept large size avatars" do
        post :update_avatar, :avatar => fixture_file_upload('/avatar/large.jpg')
        response.code.should eq "200"
      end
    end
  end
end
