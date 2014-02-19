# process
# desk = CreateDeskTicket.new(wid)
# desk.create_customer(:first_name => "first name", :last_name => "last name")
# desk.create_ticket(:subject => "subject", :priority => 1, :status => "open", :email => "agent@email.com", :body => "message body")

class CreateDeskTicket
  def initialize(website_id)
    @website = Website.find(website_id)
    data     = @website.settings(:integrations).data

    Desk.configure do |config|
      config.support_email      = @website.owner.email
      config.subdomain          = data["sub_domain"]
      config.consumer_key       = data["key"]
      config.consumer_secret    = data["secret"]
      config.oauth_token        = data["token"]
      config.oauth_token_secret = data["token_secret"]
    end
  end

  def create_ticket(args = {:subject => "Subject", :priority => 1, :status => "open", :email => "agent@email.com", :body => "Message body"})
    Desk.create_case(
      :type     => "email",
      :subject  => args[:subject],
      :priority => args[:priority],
      :status   => args[:status],
      :_links => {
        :customer => {
          :href => @customer[:_links][:self][:href],
          :class => "customer"
        }
      },
      :message  => {
        :direction => "in",
        :subject   => args[:subject],
        :body      => args[:body],
        :to        => args[:email],
        :from      => @website.owner.email
      }
    )
  end

  def create_customer(args = {:first_name => "Offerchat", :last_name => "Visitor"})
    customers = find_customers(args)
    if customers[:raw][:total_entries] == 0
      customer  = Desk.create_customer(args)
      @customer = customer[:raw]
    else
      @customer = customers[:raw][:_embedded][:entries].first
    end
  end

  def find_customers(args = {})
    Desk.customers(args)
  end
end