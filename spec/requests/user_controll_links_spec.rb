require 'spec_helper'

describe "UserControllLinks" do
  it "should have a user registration link" do
    get signup_path
    response.status.should be(200)
  end

  it "should have a login path" do
    get login_path
    response.status.should be(200)
  end

  it "should have a logout path" do
    delete logout_path
    response.status.should be(302)
  end
end
