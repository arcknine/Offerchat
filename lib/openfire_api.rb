module OpenfireApi
  class << self
    def create_user(username, password)
      url = "#{CHAT_SERVER_URL}#{USER_SERVICE_ENDPOINT}type=add&secret=#{XMPP_SECRET}&username=#{username}&password=#{user_password}"
      response = Nokogiri::XML(open(url))
    end

    def subcribe_roster(agent, visitor, name, groups)
      url = "#{CHAT_SERVER_URL}#{USER_SERVICE_ENDPOINT}type=add_roster&secret=#{XMPP_SECRET}&username=#{agent}&item_jid=#{visitor}@#{SERVER_NAME}&name=#{name}&groups=#{groups}&subscription=3"
      response = Nokogiri::XML(open(url))
    end
  end
end
