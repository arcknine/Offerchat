require 'spec_helper'

describe RegistrationsController do

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
      'email' => 'aaaa',
      'name' => '',
      'display_name' => '',
      'password' => 'a',
      'password_confirmation' => 'bss'
    }
  end



  describe "POST 'create' not logged in" do

    it "should redirect to step three when valid data" do
      @request.env["devise.mapping"] = Devise.mappings[:user]
      session[:user]={:email => 'wiredots@yahoo.com'}
      post 'create', user: user_data
      response.should redirect_to root_path
    end

    it "should redirect to step two when invalid data" do
      @request.env["devise.mapping"] = Devise.mappings[:user]
      session[:user]={:email => ''}
      post 'create', user: user_data_invalid
      response.should redirect_to signup_wizard_path('step_two')
    end



  end





end
