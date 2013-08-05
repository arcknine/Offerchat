module Offerchat
  class API < Grape::API
    use Rack::JSONP
    version 'v1', using: :header, vendor: 'offerchat'
    format :json

    desc "ping pong"
    get :ping do
      { ping: "pong"}
    end

    resource :token do
      params do
        requires :apikey, type: String, desc: "Api key."
      end
      route_param :apikey do
        get do
          website = Website.find_by_api_key(params[:apikey])
          unless website.nil?
            ip = request.env['REMOTE_ADDR']
            dataInfo = { :ipaddress => ip}
            visitor = website.visitors.new(dataInfo)
            visitor.save
            {token: visitor.token}
          else
            {error: "Invalid API Key"}
          end
        end
      end
    end

    resource :position do
      params do
        requires :apikey, type: String, desc: "Api key."
      end
      route_param :apikey do
        get do
          website = Website.find_by_api_key(params[:apikey])
          if website
            {position: website.settings(:style).position}
          else
            {error: "Api key not found!"}
          end
        end
      end
    end

    resource :settings do
      params do
        requires :apikey, type: String, desc: "Api key."
      end
      route_param :apikey do
        get do
          website = Website.find_by_api_key(params[:apikey])
          if website
            agents        = website.owner_and_agents
            chat_triggers = website.triggers
            style         = website.settings(:style).value
            online        = website.settings(:online).value
            pre_chat      = website.settings(:pre_chat).value
            post_chat     = website.settings(:post_chat).value
            offline       = website.settings(:offline).value
            settings      = { style: style, online: online, pre_chat: pre_chat, post_chat: post_chat, offline: offline }

            { settings: settings, website: website, agents: agents, chat_triggers: chat_triggers }
          else
            { error: "Api key not found!" }
          end
        end
      end
    end

    resource :checkin do
      params do
        requires :token, type: String, desc: "widget token."
      end
      route_param :token do
        get do
          visitor = Visitor.find_by_token(params[:token])
          if visitor.nil?
            { error: "Token not found!" }
          else
            website = visitor.website
            availableRoster = website.available_roster
            availableAgent = website.available_agent
            if availableRoster.nil?
              { error: "Offline" }
            else
              dataInfo = { :name => params[:name], :browser => params[:browser], :location => params[:location], :email => params[:email] }
              visitor.update_attributes(dataInfo)
              visitor.save

              visitor.chat_sessions.create(:roster_id => availableRoster.id)

              { agent_online: availableAgent, visitor_jid: availableRoster.jabber_user, visitor_pass: availableRoster.jabber_password, visitor: visitor }
            end
          end
        end
      end
    end


  end
end
