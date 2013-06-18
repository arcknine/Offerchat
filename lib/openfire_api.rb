module OpenfireApi
  class << self
    def create_user(username, password)
      url = "#{CHAT_SERVER_URL}#{USER_SERVICE_ENDPOINT}type=add&secret=#{XMPP_SECRET}&username=#{username}&password=#{user_password}"
      response = Nokogiri::XML(open(url))
    end
  end
end
