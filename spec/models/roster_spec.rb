require 'spec_helper'

describe Roster do
  it { should belong_to(:website) }

  describe "generate roster" do
    before(:each) do
      @roster = Fabricate(:roster)
    end

    it "should have jabber user" do
      @roster.jabber_user.should_not be_nil
      @roster.jabber_user.should_not be_blank
    end

    it "should have jabber password" do
      @roster.jabber_password.should_not be_nil
      @roster.jabber_password.should_not be_blank
    end
  end
end
