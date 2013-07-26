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

  let(:user_data_invalid) do
    {
      'email' => 'asdf'
    }
  end

  let(:website_data) do
    {
      'url' => 'www.mangapanda.net',
    }
  end

  let(:website_data_invalid) do
    {
      'url' => ''
    }
  end


  describe "GET 'index' or 'show' redirection " do
    it "should redirect to step one" do
      get 'index'
      response.should redirect_to signup_wizard_path('step_one')
    end

    it "should redirect to step one for no email" do
      get 'show', id:'step_two'
      response.should redirect_to signup_wizard_path('step_one')
    end

    it "should redirect to step one when not login" do
      get 'show', id:'step_five'
      response.should redirect_to new_user_session_path
    end
  end



  describe "GET 'show' not login" do
    it "should instantiate a new user step_one" do
      get 'show', id:'step_one'
      assigns(:user).should be_new_record
      response.code.should eq '200'
    end

    it "should instantiate a new user on step two" do
      session[:user] = {:email => 'test@test.com'}
      get 'show', id:'step_two'
      response.code.should eq '200'
    end
  end

  describe "GET 'show' login users" do
    login_user

    it "should redirect to step three on viewing step one" do
      get 'show', id:'step_one'
      response.should redirect_to signup_wizard_path('step_three')
    end

    it "should instantiate a login user and a new website" do
      get 'show', id:'step_three'
      assigns(:website).should be_new_record
      response.code.should eq '200'
    end

    it "should instantiate a website preview" do
      Fabricate(:website, :owner => @user)
      get 'show', id:'step_four'
      website = assigns(:website)
      website.should_not be_nil
      website.url.should_not be_empty
      website.url.should_not be_nil
      response.code.should eq '200'
    end

    it "should redirect to step_three with no website" do
      get 'show', id:'step_four'
      response.should redirect_to signup_wizard_path('step_three')
    end

    it "should instantiate a copy and pate APIkey code" do
      Fabricate(:website, :owner => @user)
      get 'show', id:'step_five'
      website = assigns(:website)
      website.api_key.should_not be_nil
      website.api_key.should_not be_empty
      response.code.should eq '200'
    end

    it "should redirect to step three when login" do
      get 'show', id:'step_five'
      response.should redirect_to signup_wizard_path('step_three')
    end
  end

  describe "POST 'update' user is not logged in" do
    it "should display error on email invalid" do
      put 'update', id:'step_one', user: user_data_invalid
      flash[:alert].should == 'Email should be valid'
      user = assigns(:user)
      user.should be_nil
      response.should redirect_to signup_wizard_path('step_one')
    end

    it "should display error on email nil" do
      put 'update', id:'step_one', user: {:email => nil}
      flash[:alert].should == 'Email should be valid'
      user = assigns(:user)
      user.should be_nil
      response.should redirect_to signup_wizard_path('step_one')
    end

    it "should go to step one when email exist" do
      user = Fabricate(:user)
      put 'update', id:'step_one', user: {:email=> user.email}
      response.should redirect_to signup_wizard_path('step_one')
    end

    it "should save user data email to session" do
      put 'update', id:'step_one', user: user_data
      session[:user][:email].should eq 'test@test.com'
      session[:user][:email].should_not be_nil
      session[:user][:email].should_not be_empty
      response.should redirect_to signup_wizard_path('step_two')
    end
  end

  describe "POST 'update' user is currenlty logged in" do
    login_user

    it "should not save a new website" do
      put 'update', id:'step_three', website: website_data_invalid
      website = assigns(:website)
      website.errors.should_not be_blank
      website.errors.should_not be_nil
      response.code.should eq '406'
    end

  end

end
