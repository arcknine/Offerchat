require 'spec_helper'

describe PasswordsController do

  context "when not signed in" do
    describe "GET 'user'" do
      it "should not be acceptable" do
        xhr :get, :show, format: :json
        response.code.should eq "401"
      end
    end
  end

  context "when user is signed in" do
    login_user

    let(:blank_fields) do
      {
        "password" => "",
        "password_confirmation" => "",
        "current_password" => ""
      }
    end

    let(:invalid_password) do
      {
        "password" => "secretpassword",
        "password_confirmation" => "secretpassword",
        "current_password" => "asd3dsfasf"
      }
    end

    let(:less_characters) do
      {
        "password" => "secre",
        "password_confirmation" => "secre",
        "current_password" => "password"
      }
    end

    let(:invalid_confirmation) do
      {
        "password" => "secretpassword",
        "password_confirmation" => "34dfadfasdf",
        "current_password" => "password"
      }
    end

    let(:valid_password) do
      {
        "password" => "secretpassword",
        "password_confirmation" => "secretpassword",
        "current_password" => "password"
      }
    end


    describe "GET 'user'" do
      it "should be allowed" do
        xhr :get, :show, format: :json
        response.code.should eq "200"
        assigns(:user).should_not be_nil
      end
    end

    describe "update user password with blank fields" do
      it "should not change password" do
        xhr :put, :update, user: blank_fields, format: :json
        response.code.should eq "401"
      end
    end

    describe "update user password with invalid current password" do
      it "should not change password" do
        xhr :put, :update, user: invalid_password, format: :json
        assigns(:user).should_not be_nil
        response.code.should eq "401"
      end
    end

    describe "update user password with less than 6 characters" do
      it "should not change password" do
        xhr :put, :update, user: less_characters, format: :json
        assigns(:user).should_not be_nil
        response.code.should eq "401"
        # JSON.parse(response.body)["errors"][0].should eq "Password should be at least 6 characters"
      end
    end

    describe "update user password with invalid confirmation password" do
      it "should not change password" do
        xhr :put, :update, user: invalid_confirmation, format: :json
        assigns(:user).should_not be_nil
        response.code.should eq "401"
        # JSON.parse(response.body)["errors"][0].should eq "New password and verify password did not match"
      end
    end

    describe "update user password with valid password" do
      it "should change password to new one" do
        xhr :put, :update, user: valid_password, format: :json
        assigns(:user).should_not be_nil
        response.code.should eq "200"
        # JSON.parse(response.body)["msg"].should eq "Your changes have been saved"
      end
    end

  end

end
