class OfflineTicketWorker
  include Sidekiq::Worker

  def perform(wid, name, email, message)
    @website = Website.find(wid)
    if @website.settings(:integrations).integration == "desk"
      self.send_desk name, email, message
    elsif @website.settings(:integrations).integration == "zendesk"
      self.send_zendesk name, email, message
    end
  end

  def send_desk(name, email, message)
    names = name.split(" ")
    if names.length > 1
      last_name  = names.pop
      first_name = names.join(" ")
    else
      last_name  = params[:name]
      first_name = ""
    end

    desk = CreateDeskTicket.new(@website.id)
    desk.create_customer(
      :first_name => first_name,
      :last_name  => last_name,
      :emails     => [{ :type => "work", :value => email }]
    )
    desk.create_ticket(
      :subject  => "Offline Message",
      :priority => 1,
      :status   => "open",
      :email    => @website.owner.email,
      :body     => message
    )
  end

  def send_zendesk(name, email, message)
    company  = @website.settings(:integrations).data[:sub_domain]
    username = @website.settings(:integrations).data[:email]
    token    = @website.settings(:integrations).data[:token]

    client = ZendeskAPI::Client.new do |config|
      config.url = "https://#{company}.zendesk.com/api/v2"
      config.username = username
      config.token = token
    end

    client.insert_callback do |env|
      puts env[:response_headers][:status]
      if env[:response_headers][:status] == "201 Created"
        puts "Something went wrong while creating your ZenDesk ticket."
      end
    end

    client.users.create(:name => name, :email => email)
    client.tickets.create(
      :subject => "Offline Message",
      :comment => {
        :value => message
      },
      :priority  => "low",
      :type      => "question",
      :status    => "open",
      :requester => {
        :name  => name,
        :email => email
      }
    )
  end
end