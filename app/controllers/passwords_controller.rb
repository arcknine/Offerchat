class PasswordsController < ApplicationController
  before_filter :authenticate_user!
  respond_to :json

  def show
    @user = current_user
  end

  def update
    @user = current_user

    if @user.update_with_password(params[:user])
      sign_in(@user, :bypass => true)
      redirect_to root_path, :notice => "Your Password has been updated!"
    else
      respond_with @user
    end
    
    #if user[:password].blank? or user[:password_confirmation].blank? or user[:current_password].blank?
    #  render json: {errors: ["All fields are required"]}, status: 401
    #else
    #  if @user.valid_password?(user[:current_password])
    #    if user[:password] == user[:password_confirmation]
    #      if @user.update_with_password(user)
    #
    #        # Sign in the user by passing validation in case his password changed
    #        sign_in @user, :bypass => true
    #        render json: {success: true, msg: "Your changes have been saved"}
    #        
    #      else
    #        respond_to @user
    #      end
    #    else
    #      respond_to @user
    #    end
    #  else
    #    respond_to @user
    #  end
    #end

  end

end