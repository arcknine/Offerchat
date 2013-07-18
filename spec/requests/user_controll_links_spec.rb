require 'spec_helper'

describe "UserControllLinks" do
  it "should have a user registration link" do
    #get signup_path
    get signup_wizard_path('step_one')
    response.status.should be(200)
  end

  it "should have a login path" do
    #get login_path
    get new_user_session_path
    response.status.should be(200)
  end

  it "should have a logout path" do
    #delete logout_path
    delete destroy_user_session_path
    response.status.should be(302)
  end
end
