class User_Mailer_Worker
  include Sidekiq::Worker

  def perform(id)
    user = User.find(id)

  end
end

