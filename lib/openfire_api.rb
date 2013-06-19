module OpenfireApi
  class << self
    def create_user(username, password)
      url = "#{CHAT_SERVER_URL}#{USER_SERVICE_ENDPOINT}type=add&secret=#{CHAT_SERVER_SECRET}&username=#{username}&password=#{password}"
      url = url.gsub(" ", "+")
      response = Nokogiri::XML(open(url))

      if response.xpath("//result").children.text == "ok"
        true
      end
    end

    def subcribe_roster(agent, visitor, name, groups)
      url = "#{CHAT_SERVER_URL}#{USER_SERVICE_ENDPOINT}type=add_roster&secret=#{CHAT_SERVER_SECRET}&username=#{agent}&item_jid=#{visitor}@#{CHAT_SERVER_NAME}&name=#{name}&groups=#{groups}&subscription=3"
      url = url.gsub(" ", "+")
      response = Nokogiri::XML(open(url))

      if response.xpath("//result").children.text == "ok"
        true
      end
    end
  end
end
