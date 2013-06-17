require 'spec_helper'

describe Website do
  describe "website creation" do
    before(:each) do
      @website = Fabricate(:website)
    end

    it "should have url" do
      @website.url.should_not be_nil
      @website.url.should_not be_blank
    end

    it "should validate the url format" do
      website = Website.new(:url => "testurl")
      website.should have(1).error_on(:url)

      localhost = Website.new(:url => "http://localhost")
      localhost.should_not have(1).error_on(:url)

      well_formed = Website.new(:url => "http://www.nice-url.com")
      well_formed.should_not have(1).error_on(:url)
    end

    it "should have default settings" do
      @wesbite.settings.should_not be_nil
      @website.settings.should_not be_blank

      @website.settings[:style].should_not be_nil
      @website.settings[:style].should_not be_blank
    end
  end
end
