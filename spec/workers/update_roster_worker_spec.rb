require 'spec_helper'

describe UpdateRosterWorker do
  before(:each) do
    @roster  = Fabricate(:roster)
  end

  it "should create and subscribe roster" do
    expect {
      UpdateRosterWorker.perform_async(@roster.id, "name")
    }.to change( UpdateRosterWorker.jobs, :size ).by(1)
  end
end