class JabberUserWorker
  include Sidekiq::Worker

  def perform(id)
    user = User.find(id)
    OpenfireApi.create_user(user.jabber_user, user.jabber_password)
  end
end
