require 'spec_helper'

describe User do

  before(:each) do
    @user = Fabricate(:user)
  end

  it { should have_many :accounts }
  it { should have_many :websites }

  describe "User Registration" do
    it "should have email address" do
      @user.email.should_not be_blank
      @user.email.should_not be_nil
    end

    it "should have a name" do
      @user.name.should_not be_blank
      @user.name.should_not be_nil
      @user.name.length.should <= 25
    end

    it "should have a default display name" do
      @user.display_name.should_not be_blank
      @user.display_name.should_not be_nil
      @user.display_name.length.should <= 15
    end

  end


  describe "After Create" do
    #@user.should have(1).@websites
  end










end
