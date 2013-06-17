require 'spec_helper'

describe Account do
  before(:account) do
    @account = Fabricate(:account)
  end

  it "should have user id" do
    @account.user_id.should_not be_nil
  end
end
