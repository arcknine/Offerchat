class ZendeskService
  def initialize(subject, desc, prio, type)
    @subject, @desc, @prio, @type = subject, desc, prio, type
  end

  def create_ticket
    client = ZendeskAPI::Client.new do |config|
      config.url = "https://kageron.zendesk.com/api/v2"
      config.username = "eralphamodia@gmail.com"
      config.token = "YNt53MuiHkdewWV50OpgxYYxmJhUiOXau9zC6lTW"
    end

    puts 'RESPONSEEEEEEEEE'
    client.insert_callback do |env|
      puts env
      puts env[:response_headers]
    end

    client.tickets.create(:subject => @subject, :comment => { :value => @desc }, :priority => @prio, :type => @type )

  end
end
