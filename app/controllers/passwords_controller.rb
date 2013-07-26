class PasswordsController < ApplicationController
  before_filter :authenticate_user!
  respond_to :json

  def show
    @user = current_user
  end

  def update
    @user = User.find(current_user.id)

    if params[:password].blank? or params[:password_confirmation].blank? or params[:current_password].blank?
      render json: {errors: ["All fields are required"]}, status: 401
    else
      if @user.valid_password?(params[:current_password])
        if params[:password] == params[:password_confirmation]
          if @user.update_with_password(params.except(:id).except(:action).except(:controller).except(:success).except(:msg))
            # Sign in the user by passing validation in case his password changed
            sign_in @user, :bypass => true
            render json: {success: true, msg: "Your changes have been saved"}
          else
            respond_with @user
          end
        else
          render json: {errors: {password: ["New password and verify password did not match"], password_confirmation: ["New password and verify password did not match"]}}, status: 401
        end
      else
        render json: {errors: {current_password: ["Incorrect current password"]}}, status: 401
      end
    end
  end

end