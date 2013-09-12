require 'spec_helper'

describe QuickResponse do
  it { should validate_presence_of :message }
  it { should validate_presence_of :shortcut }
  it { should belong_to :website }
end
