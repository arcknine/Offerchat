class Rating < ActiveRecord::Base
  belongs_to :user
  belongs_to :website

  attr_accessible :down, :up, :token, :user, :website

  def self.filter(params)
    rating = Rating.select("SUM(up) as up, SUM(down) as down")

    if params[:from] && params[:to]
      from = params[:from]
      to   = params[:to]
      rating = rating.where(created_at: from..to)
    end

    if params[:user_id]
      rating = rating.where(:website_id => params[:website_id], :user_id => params[:user_id])
    else
      rating = rating.where(:website_id => params[:website_id])
    end
    rating = rating.group("website_id")

    rating.last
  end
end
