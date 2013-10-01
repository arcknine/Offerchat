require 'spec_helper'

describe Stats do
  it { should belong_to :user }
  it { should belong_to :website }
end
