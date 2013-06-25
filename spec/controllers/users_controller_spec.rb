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
          "role" => Account::AGENT,
          "website_id" => @website.id
        }]
      end

      def do_create
        xhr :post, :create, user: valid_user_post, account: valid_account_post, format: :json
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
  end
end
