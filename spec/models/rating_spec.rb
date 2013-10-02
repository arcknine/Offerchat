require 'spec_helper'

describe Rating do
  it { should belong_to :user }
  it { should belong_to :website }

  describe "Rating functions"
    before(:each) do
      @user = Fabricate(:user)
      @web  = Fabricate(:website, :owner => Fabricate(:user))

      @rating  = Fabricate(:rating, :user => @user, :website => @web)
    end

    it "#self.filter" do
      filter = { :user_id => [@user.id], :website_id => [@web.id] }
      Rating.filter(filter).should_not be_nil
    end
end
