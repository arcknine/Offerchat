class UpdateRosterService
  def initialize(rid, name)
    @roster = Roster.find(rid)
    users   = @roster.website.accounts.collect(&:user_id)
    @users  = User.where(id: users)
    @name   = name
    @roster
  end

  def update_roster
    @users.each do |u|
      OpenfireApi.update_roster(u.jabber_user, @roster.jabber_user, @name, @roster.website.url)
      sleep(1)
    end
  end
end