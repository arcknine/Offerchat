module OpenfireApi
  def self.create_user(username, password)

    url = "#{ENV["CHAT_SERVER_URL"]}#{ENV["USER_SERVICE_ENDPOINT"]}type=add&secret=#{ENV["CHAT_SERVER_SECRET"]}&username=#{username}&password=#{password}"
    url = url.gsub(" ", "+")

    unless Rails.env.test?
      response = Nokogiri::XML(open(url))
      if response.xpath("//result").children.text == "ok"
        true
      end
    else
      true
    end

  end

  def self.subcribe_roster(agent, visitor, name, groups)

    url = "#{ENV["CHAT_SERVER_URL"]}#{ENV["USER_SERVICE_ENDPOINT"]}type=add_roster&secret=#{ENV["CHAT_SERVER_SECRET"]}&username=#{agent}&item_jid=#{visitor}@#{CHAT_SERVER_NAME}&name=#{name}&groups=#{groups}&subscription=3"
    url = url.gsub(" ", "+")

    unless Rails.env.test?
      response = Nokogiri::XML(open(url))
      if response.xpath("//result").children.text == "ok"
        true
      end
    else
      true
    end
  end

  def self.unsubcribe_roster(agent, visitor)

    url = "#{ENV["CHAT_SERVER_URL"]}#{ENV["USER_SERVICE_ENDPOINT"]}type=delete_roster&secret=#{ENV["CHAT_SERVER_SECRET"]}&username=#{agent}&item_jid=#{visitor}@#{CHAT_SERVER_NAME}&subscription=-1"
    url = url.gsub(" ", "+")

    unless Rails.env.test?
      response = Nokogiri::XML(open(url))
      if response.xpath("//result").children.text == "ok"
        true
      end
    else
      true
    end
  end
end
