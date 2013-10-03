class Stat < ActiveRecord::Base
  attr_accessible :active, :missed, :proactive, :user, :website

  belongs_to :user
  belongs_to :website

  def self.filter(params)
    stats = Stat.select("SUM(proactive) as proactive, SUM(active) as active, SUM(missed) as missed, created_at")

    if params[:from] && params[:to]
      from = params[:from]
      to   = params[:to]
      stats = stats.where("DATE(created_at) BETWEEN DATE(?) AND DATE(?)", from, to)
    end


    if params[:user_id]
      stats = stats.where(:website_id => params[:website_id], :user_id => params[:user_id])
    else
      stats = stats.where(:website_id => params[:website_id])
    end

    stats = stats.group("DATE(created_at)")

    stats
  end
end
