require 'spec_helper'

describe User do
  
  before(:each) do
    @user = Fabricate(:user)
    @user.save
  end
  
  it { should have_many :accounts }
  it { should have_many :websites }
  
  it "should only have an avatar of valid image type" do
    @user.avatar = File.new(Rails.root + 'spec/support/images/avatar.png')
    @user.save
    @user.avatar.should_not be_nil
  end
  
  it "should not accept image of invalid file types" do
    expect{
      @user.avatar = File.new(Rails.root + 'spec/support/images/avatar.pdf')
      @user.save
    }.to raise_exception
  end
end