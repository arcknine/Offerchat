class User < ActiveRecord::Base
  require 'securerandom'

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  has_many :accounts
  has_many :websites, :foreign_key => "owner_id"

  attr_accessible :email, :password, :password_confirmation, :remember_me,
    :name, :display_name, :jabber_user, :jabber_password

  after_create :create_jabber_account

  private

  def create_jabber_account
    self.update_attributes(:jabber_user => "#{self.id}#{self.created_at.to_i}", :jabber_password => SecureRandom.hex(8))
    # Create the account on Openfire
    JabberUserWorker.perform_async(self.id)
  end
end
