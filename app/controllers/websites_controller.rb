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
    @website = Website.find_by_id(params[:id])
    zendesk = @website.settings(:integrations).data

    company = zendesk[:sub_domain]

    client = ZendeskAPI::Client.new do |config|
      config.url = "https://#{company}.zendesk.com/api/v2"
      config.username = zendesk[:email]
      config.token = zendesk[:token]
    end

    options = {:subject => params[:subject], :comment => { :value => params[:desc] }, :priority => params[:prio], :type => params[:type], :status => params[:status]}

    unless params[:visitor][:name].blank?
      options[:requester] = {}
      options[:requester][:name] = params[:visitor][:name]

      unless params[:visitor][:email].blank?
        options[:requester][:email] = params[:visitor][:email]
      end
    end

    res = client.tickets.create(options)

    if res.nil?
      render json: "Something went wrong while creating your ZenDesk ticket.", status: 401
    end
  end

  def desk
    desk = CreateDeskTicket.new(params[:id])

    unless params[:name].empty?
      names      = params[:name].split(" ")
      if names.length > 1
        last_name  = names.pop
        first_name = names.join(" ")
      else
        last_name  = params[:name]
        first_name = ""
      end
    else
      last_name  = "Visitor"
      first_name = "Offerchat"
    end

    args = { :first_name => first_name, :last_name  => last_name }

    # additional information
    args[:company]       = params[:company] unless params[:company].blank?
    args[:title]         = params[:title] unless params[:title].blank?
    args[:phone_numbers] = [params[:phone]] unless params[:phone].blank?
    args[:emails]        = [{ type: "work", value: params[:email] }] unless params[:email].blank?

    desk.create_customer(args)

    result = desk.create_ticket(
      :subject  => params[:subject],
      :priority => params[:priority],
      :status   => params[:status],
      :email    => current_user.email,
      :body     => params[:message]
    )

    unless result[:raw][:message].blank?
      render json: "Something went wrong while creating your Desk ticket.", status: 401
    end
  end

  def zoho
    puts 'paramsssssssssssss'
    puts params.inspect

    zoho = ZohoService.new(params[:id], params[:visitor], params[:task])
    contact_id = zoho.create_update_contact

    puts 'contacccccccc'
    puts contact_id

    unless contact_id.nil?
      result = zoho.create_task(contact_id)
      puts 'resultttttttt'
      puts result
    end



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
