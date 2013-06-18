require 'spec_helper'

describe Account do

  it { should belong_to :website }
  it { should belong_to :user }

  before(:each) do
    @account = Fabricate(:account)
  end
end
