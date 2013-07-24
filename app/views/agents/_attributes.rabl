attributes :id, :email, :password, :name, :display_name, :jabber_user, :jabber_password, :avatar, :created_at, :updated_at

node do |user|
  sites = []
  @owner.websites.each do |website|
    user.accounts.select("id, role, website_id").each do |account|
      if website.id == account.website_id
        sites << {
          :id => website.id,
          :account_id => account.id,
          :role => account.role,
          :url => website.url,
          :name => website.name
        }
      else
        sites << {
          :id => website.id,
          :account_id => nil,
          :role => 0,
          :url => website.url,
          :name => website.name
        }
      end
    end
  end
  {
    :pending => user.accounts.first.pending?,
    :websites => sites
  }
end