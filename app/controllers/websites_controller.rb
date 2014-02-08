class WebsitesController < ApplicationController
  before_filter :authenticate_user!
  before_filter :current_user_has_website? , :except => [:create]
  respond_to :json

  def index
    # @websites = current_user.all_sites
    # @websites = @all_sites
  end

  def owned
    @websites = current_user.websites
  end

  def managed
    @websites = current_user.admin_sites
  end

  def new
    @website = current_user.websites.new
  end

  def triggers
    @website = current_user.websites.find params[:id]
    @triggers = @website.triggers
  end

  def show
    @website = current_user.websites.find params[:id]
  end

  def webmaster_code
    if params[:email].present? && params[:api_key].present? && validate_email(params[:email].to_s)
      UserMailer.delay.send_to_webmaster( params[:email].to_s, current_user.name, params[:api_key].to_s )
      render json: { success: {"success" => ["email sent!"]} }, status: 200
    else
      render json: { errors: {"email" => ["should be valid and not blank"]} }, status: 401
    end

  end

  def create

    @website = current_user.websites.new(params[:website])
    @website.settings(:style).gradient = params['gradient']
    @website.settings(:style).theme = params['color']
    @website.settings(:style).rounded = true
    @website.settings(:online).agent_label = params['greeting']
    @website.settings(:style).position = params['position']

    unless @website.save
      respond_with @website
    end
  end

  def update
    if params[:website][:name].blank?
      render json: { errors: {"name" => ["should not be blank"]} }, status: 401
    elsif params[:website][:url].blank?
      render json: { errors: {"url" => ["should not be blank"]} }, status: 401
    else
      @website = current_user.websites.find(params[:id])

      unless @website.update_attributes(params[:website].except(:plan).except(:attention_grabber))
        respond_with @website
      end
    end
  end

  def update_settings
    @website = current_user.find_managed_sites(params[:id])

    unless @website.save_settings(params[:settings])
      respond_with @website
    end
  end

  def destroy
    @website = Website.find(params[:id])
    if @website.destroy
      head :no_content
    end
  end

  def update_attention_grabber
    @website = current_user.websites.find params[:id]
    unless @website.update_attribute('attention_grabber', params[:attention_grabber])
      respond_with @website
    end
  end

  def zendesk_auth
    puts params

    @website = Website.find_by_id(params[:id])
    company = @website.settings(:zendesk).company
    username = @website.settings(:zendesk).username
    token = @website.settings(:zendesk).token

    subject = params[:subject]
    desc = params[:desc]
    type = params[:type]
    prio = params[:prio]

    res = ZendeskService.new(subject, desc, prio, type)
    res.create_ticket

    # res = URI.encode('curl https://kageron.zendesk.com/api/v2/tickets.json -d \'{ "ticket": { "subject":"My OFFICE is on fire!", "comment": { "body":"The smoke is very colorful." }, "priority":"urgent", "type":"question" } }\' -H "Content-Type: application/json" -v -u eralphamodia@gmail.com/token:YNt53MuiHkdewWV50OpgxYYxmJhUiOXau9zC6lTW')
    # response = HTTParty.post(res)
    # puts response.body

    # res = HTTParty.post("https://kageron.zendesk.com/api/v2/tickets.json", {
    #   :body => [ { "ticket" => { "subject"=>"My OFFICE is on fire!", "comment" => { "body"=>"The smoke is very colorful." }, "priority"=>"urgent", "type"=>"question" } } ].to_json,
    #   :basic_auth => { :user => "eralphamodia@gmail.com", :token => "YNt53MuiHkdewWV50OpgxYYxmJhUiOXau9zC6lTW" },
    #   :headers => { 'Content-Type' => 'application/json' }
    # })
    # puts "RESPONSE"
    # puts res.body

    # subject = "First Offerchat Ticket"
    # desc    = "This is the first offerchat official first ticket"
    # type    = "question"
    # prio    = "urgent"

    # require 'zendesk_api'

    # client = ZendeskAPI::Client.new do |config|
    #   config.url = "https://kageron.zendesk.com/api/v2"
    #   config.username = "eralphamodia@gmail.com"
    #   config.token = "YNt53MuiHkdewWV50OpgxYYxmJhUiOXau9zC6lTW"
    # end

    # puts 'RESPONSEEEEEEEEE'
    # client.insert_callback do |env|
    #   puts env[:response_headers]
    # end

    # client.tickets.create(:subject => "SUBJECT NI HAAAAAAAAA", :comment => { :value => desc }, :priority => prio, :type => type )
    # zendesk_client.tickets.create(:subject => subject, :comment => { :value => desc }, :priority => prio, :type => type )
    # ZendeskAPI::Ticket.create(:subject => subject, :comment => { :value => desc }, :priority => prio, :type => type )

  end

  private
  def validate_email(email)
    email_regex = %r{
      ^ # Start of string
      [0-9a-z] # First character
      [0-9a-z.+]+ # Middle characters
      [0-9a-z] # Last character
      @ # Separating @ character
      [0-9a-z] # Domain name begin
      [0-9a-z.-]+ # Domain name middle
      [0-9a-z] # Domain name end
      $ # End of string
    }xi # Case insensitive

    if (email =~ email_regex) == 0
      return true
    else
      return false
    end
  end



end
