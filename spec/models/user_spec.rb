require 'spec_helper'

describe User do
  
  before(:each) do
    @user = Fabricate(:user)
  end
  
  it { should have_many :accounts }
  it { should have_many :websites }
  
  it "should have an avatar" do
    
  end
end
