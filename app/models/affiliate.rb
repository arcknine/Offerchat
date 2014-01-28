class Affiliate < ActiveRecord::Base
  attr_accessible :enabled, :name, :description

  has_many :users

  before_create :generate_name

  def generate_name
    begin
      random_token = ('a'..'z').to_a.shuffle[0,8].join
    end while Affiliate.where(name: random_token).exists?

    self.name = random_token
  end
end
