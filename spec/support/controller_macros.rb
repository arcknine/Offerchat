module ControllerMacros
  def login_user
    before(:each) do
      @request.env["devise.mapping"] = Devise.mappings[:user]
      @user = Fabricate(:user)
      #user.confirm! # or set a confirmed_at inside the factory. Only necessary if you are using the confirmable module
      sign_in @user
    end
  end

  def login_starter_user
    before(:each) do
      @request.env["devise.mapping"] = Devise.mappings[:user]
      @user = Fabricate(:starter_user)
      sign_in @user
    end
  end

  def login_personal_user
    before(:each) do
      @request.env["devise.mapping"] = Devise.mappings[:user]
      @user = Fabricate(:personal_user)
      sign_in @user
    end
  end

  def login_business_user
    before(:each) do
      @request.env["devise.mapping"] = Devise.mappings[:user]
      @user = Fabricate(:business_user)
      sign_in @user
    end
  end

  def login_enterprise_user
    before(:each) do
      @request.env["devise.mapping"] = Devise.mappings[:user]
      @user = Fabricate(:enterprise_user)
      sign_in @user
    end
  end

  def generate_website
    before(:each) do
       @website = Fabricate(:website, :owner => @user)
       @account = Fabricate(:account, :website => @website)
       @trigger = Fabricate(:trigger, :website => @website)
    end
  end
end

