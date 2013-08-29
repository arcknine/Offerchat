class PasswordsController < ApplicationController
  before_filter :authenticate_user!
  respond_to :json

  def show
    @user = current_user
  end

  def update
    @user = User.find(current_user.id)

    if params[:password].blank? or params[:password_confirmation].blank? or params[:current_password].blank?
      err = {}
      err[:current_password] = ["should not be blank"] if params[:current_password].blank?
      err[:password] = ["should not be blank"] if params[:password].blank?
      err[:password_confirmation] = ["should not be blank"] if params[:password_confirmation].blank?
      render json: {errors: err}, status: 401
    else
      if @user.valid_password?(params[:current_password])
        if params[:password] == params[:password_confirmation]
          if @user.update_with_password(params.except(:id).except(:action).except(:controller).except(:success).except(:msg).except(:avatar))
            # Sign in the user by passing validation in case his password changed
            sign_in @user, :bypass => true
            render json: {success: true, msg: "Your changes have been saved"}
          else
            respond_with @user
          end
        else
          render json: {errors: {password: ["does not match"], password_confirmation: ["does not match"]}}, status: 401
        end
      else
        render json: {errors: {current_password: ["is incorrect"]}}, status: 401
      end
    end
  end

end
