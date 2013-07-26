attributes :id, :email, :password, :name, :display_name, :jabber_user, :jabber_password, :avatar, :created_at, :updated_at

node do |user|
  {
    :pending => user.accounts.first.pending?,
    :websites => JSON.parse(user.accounts.select("id, role, website_id").to_json),
  }
end