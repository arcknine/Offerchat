require 'spec_helper'

describe Note do
  it { should belong_to :visitor }

  describe 'create new record' do

    before(:each) do
      @note = Fabricate(:note)
    end

    it "should have a message" do
      @note.message.should_not be_nil
      @note.message.should_not be_blank
    end

  end
end
