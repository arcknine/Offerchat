class CreateWebsiteService
  def initialize(user)
    @user = user
  end

  def create
    @website = Website.new(:name => "My Website", :owner => @user, :url => "www.mywebsite.com")
    @website.save!
  end
end
