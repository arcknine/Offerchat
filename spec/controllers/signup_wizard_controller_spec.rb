require 'spec_helper'

describe SignupWizardController do

  let(:user_data) do
    {
      'email' => 'test@test.com',
      'name' => 'Rommel Esparcia',
      'display_name' => 'Wiredots',
      'password' => 'secretpass',
      'password_confirmation' => 'secretpass'
    }
  end

  let(:website_data) do
    {
      'url' => 'www.mangapanda.net',
      'owner_id' => 1
    }
  end


  describe "GET 'index'" do
    it "should redirect to step one" do
      get 'index'
      response.should redirect_to signup_wizard_path('step_one')
    end
  end

  describe "GET 'show'" do
    it "should instantiate a new user" do
      get 'show', id:'step_one'
      assigns(:user).should be_new_record
      response.code.should eq '200'
    end
    it "should instantiate a new user" do
      get 'show', id:'step_two'
      assigns(:user).should be_new_record
      response.code.should eq '200'
    end

    it "should instantiate a login user and a new website" do
      get 'show', id:'step_three'
      # assigns(:user).should_not be_nil
      assigns(:website).should be_new_record
      response.code.should eq '200'
    end

    it "should instantiate a website preview" do
      get 'show', id:'step_four'
      response.code.should eq '200'
    end

    it "should instantiate a copy and pate APIkey code" do
      get 'show', id:'step_five'
      response.code.should eq '200'
    end


  end

  describe "POST 'create'" do
    login_user
    it "should save user data email to session" do
      post 'create', id:'step_one', user: user_data
      session[:user][:email].should eq 'test@test.com'
      response.should redirect_to signup_wizard_path('step_two')
    end

    it "should save a new website data" do
      post 'create', id:'step_three', website: website_data
      response.should redirect_to signup_wizard_path('step_four')
    end

    # it "should save user data name, display name, password" do
    #   post 'create', id:'step_two', user: user_data
    #   session[:user][:name].should eq 'Rommel Esparcia'
    #   session[:user][:display_name].should eq 'Wiredots'
    #   session[:user][:password].should eq 'secretpass'
    #   User.all.count.should eq 1
    #   # expect{
    #   #   Fabricate(:user)
    #   # }.to change(User.all.count).by(1)
    #   response.should redirect_to signup_wizard_path('step_three')
    # end

  end

end
