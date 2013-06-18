class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me
  # attr_accessible :title, :body
  validates_presence_of :name
  validates_length_of :name, :in => 4..15
  has_many :accounts
  has_many :websites, :foreign_key => "owner_id"


  before_create :generate_display_name


  private

  def generate_display_name
      split = self.name.split(' ', 2)
      self.display_name = split.first
  end
end
