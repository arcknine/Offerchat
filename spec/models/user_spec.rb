require 'spec_helper'

describe User do
  it { should have_many :accounts }
  it { should have_many :websites }
end
