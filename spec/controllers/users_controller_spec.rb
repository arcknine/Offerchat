require 'spec_helper'

describe UsersController do

  context "when not signed in" do
    describe "GET 'index'" do
      it "should not be acceptable" do
        xhr :get, :index, format: :json
        response.code.should eq "401"
      end
    end
  end

  context "when signed in" do
    login_user

    let(:valid_user_post) do
      { "email" => "user001@offerchat.com" }
    end

    let(:invalid_user_post) do
      { "email" => "not a valid email" }
    end

    describe "GET 'index' user has no website" do
      it "should not be viewed if user has no website" do
        xhr :get, :index, format: :json
        response.code.should eq "401"
      end
    end

    # describe "GET 'index' as admin" do
    #   before(:each) do
    #     Fabricate(:account, :user => @user, :role => Account::ADMIN)
    #   end

    #   pending "should be viewed" do
    #     xhr :get, :index, format: :json
    #     response.code.should eq "200"
    #   end
    # end

    describe "GET 'index' user has website" do
      generate_website
      before(:each) do
        Fabricate(:account, :user => Fabricate(:user), :website => @website, :role => Account::AGENT)
      end

      it "should viewed if user has website" do
        xhr :get, :index, format: :json
        response.code.should eq "200"
      end

       it "should get all agents under my account" do
        xhr :get, :index, format: :json
        assigns(:agents).should_not be_empty
      end
    end

    describe "POST 'create'" do
      generate_website

      let(:valid_account_post) do
        [{
          "is_admin"   => true,
          "website_id" => @website.id
        }]
      end

      let(:invalid_account_post) do
        [{
          "is_admin"   => true,
          "website_id" => nil
        }]
      end

      def do_create(type = 'valid')
        if type == 'valid'
          xhr :post, :create, user: valid_user_post, account: valid_account_post, format: :json
        else
          xhr :post, :create, user: invalid_user_post, account: valid_account_post, format: :json
        end
      end

      it "should have email and password" do
        do_create
        user = assigns(:user)

        user.email.should_not be_nil
        user.email.should_not be_empty

        user.password.should_not be_nil
        user.password.should_not be_empty

        user.password_confirmation.should_not be_nil
        user.password_confirmation.should_not be_empty
      end

      it "should not create user if invalid email" do
        do_create("invalid")
        JSON.parse(response.body)["errors"].should_not be_blank
        response.code.should eq "401"
      end

      it "should create new user" do
        expect {
          do_create
        }.to change(User, :count).by(1)
      end

      it "should created 1 account" do
        expect {
          do_create
        }.to change(Account, :count).by(1)
      end
    end

    describe "DELETE 'destory" do
      generate_website

      before(:each) do
        @usr = Fabricate(:user)
      end

      def do_destory
        xhr :delete, :destroy, id: @usr.id, format: :json
      end

      it "should remove 1 agent" do
        expect {
          do_destory
        }.to change(User, :count)
      end

      it "should return json" do
        do_destory
        response.code.should eq "204"
      end
    end

    describe "PUT 'update'" do
      generate_website
      before(:each) do
        @user1 = Fabricate(:user)
        @account = Fabricate(:account, :user => @user1, :role => Account::AGENT, :website => @website)
      end

      let(:valid_put) do
        [{
          "is_admin"   => true,
          "website_id" => @website.id,
          "account_id" => @account.id
        }]
      end

      let(:invalid_put) do
        [{
          "is_admin"   => true,
          "website_id" => nil,
          "account_id" => @account.id
        }]
      end

      def do_update(type = "valid")
        if type == "valid"
          xhr :put, :update, id: @user1.id, account: valid_put, format: :json
        else
          xhr :put, :update, id: @user1.id, account: invalid_put, format: :json
        end
      end

      it "should return user" do
        do_update
        assigns(:user).should_not be_nil
      end

      it "should update assigned website and role" do
        do_update
        user = assigns(:user)
        assigns(:user).accounts.first.role.should eq(Account::ADMIN)
        assigns(:user).accounts.first.website_id.should eq(@website.id)
      end

      it "should not update user if no website is checked" do
        do_update("invalid")
        JSON.parse(response.body)["errors"].should_not be_blank
        response.code.should eq "401"
      end
    end
  end
end
