class CouponsController < ApplicationController
  before_filter :authenticate_user!
  respond_to :json

  def retrieve
    render :json => Stripe::Coupon.all.data
  end
end