class PasswordsController < ApplicationController
  before_filter :authenticate_user!
  respond_to :json

  def show
    @user = current_user
  end

  def update
    @user = User.find(current_user.id)
    # puts params[:user]


    if params[:user][:password].blank? or params[:user][:password_confirmation].blank? or params[:user][:current_password].blank?
      render json: {errors: ["All fields are required"]}, status: 401
    # elsif params[:user][:password]

    else
      if @user.valid_password?(params[:user][:current_password])
        if params[:user][:password] == params[:user][:password_confirmation]
          if @user.update_with_password(params[:user])
            # Sign in the user by passing validation in case his password changed
            sign_in @user, :bypass => true
            render json: {success: true, msg: "Your changes have been saved"}
          else
            render json: {errors: @user.errors.full_messages}, status: 401
          end
        else
          render json: {errors: ["New password and verify password did not match"]}, status: 401
        end
      else
        render json: {errors: ["Incorrect current password"]}, status: 401
      end
    end

  end

end