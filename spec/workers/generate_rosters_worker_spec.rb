require 'spec_helper'

describe GenerateRostersWorker do
  before(:each) do
    @user = Fabricate(:user)
    @website = Fabricate(:website, :owner => @user)
  end

  it "should create and subscribe roster" do
    expect {
      GenerateRostersWorker.perform_async(@website.id)
    }.to change( GenerateRostersWorker.jobs, :size ).by(1)
  end
end