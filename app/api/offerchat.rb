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
            { position: website.settings(:style).position, footer: website.settings(:footer).enabled }
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
            agents    = website.widget_owner_agents
            triggers  = website.triggers
            anyAgents = website.available_agent

            style = website.settings(:style)
            style = { gradient: style.gradient, position: style.position, rounded: style.rounded, theme: style.theme, language: style.language }

            online = website.settings(:online)
            online = { agent_label: online.agent_label, greeting: online.greeting, header: online.header, placeholder: online.placeholder }

            pre_chat = website.settings(:pre_chat)
            pre_chat = { description: pre_chat.description, enabled: pre_chat.enabled, header: pre_chat.header, message_required: pre_chat.message_required, email_required: pre_chat.email_required }

            post_chat = website.settings(:post_chat)
            post_chat = { description: post_chat.description, enabled: post_chat.enabled, header: post_chat.header, email: post_chat.email }

            offline = website.settings(:offline)
            offline = { description: offline.description, email: offline.email, enabled: offline.enabled, header: offline.header }

            settings = { style: style, online: online, pre_chat: pre_chat, post_chat: post_chat, offline: offline, triggers: triggers }

            { website: { id: website.id, name: website.name, url: website.url, agents: agents, settings: settings }, any_agents_online: anyAgents }
          else
            { error: "Api key not found!" }
          end
        end
      end
    end

    resource :any_agents_online do
      params do
        requires :apikey, type: String, desc: "Api key."
      end

      route_param :apikey do
        get do
          website   = Website.find_by_api_key(params[:apikey])
          if website
            anyAgents = website.available_agent

            { any_agents_online: anyAgents, website_id: website.id }
          else
            { error: "Invalid API Key" }
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
            if availableRoster.blank?
              { error: "Offline" }
            else
              unless params[:name].blank?
                dataInfo = { :name => params[:name], :browser => params[:browser], :location => params[:location], :email => params[:email], :operating_system => params[:operating_system], :country_code => params[:country_code] }
              else
                dataInfo = { :browser => params[:browser], :location => params[:location], :email => params[:email], :operating_system => params[:operating_system], :country_code => params[:country_code]}
              end
              visitor.update_attributes(dataInfo)
              visitor.save
              visitor.chat_sessions.create(:roster_id => availableRoster.id)

              availableRoster.update_attributes(:last_used => Time.now )
              availableRoster.save

              UpdateRosterWorker.perform_async(availableRoster.id, visitor.name)

              { roster: availableRoster, visitor: visitor }
            end
          end
        end
      end
    end


    resource :checkout do
      params do
        requires :token, type: String, desc: "widget token."
      end
      route_param :token do
        get do
          visitor = Visitor.find_by_token(params[:token])
          if visitor.nil?
            { error: "Token not found!" }
          else
            roster = visitor.chat_sessions.last.roster
            roster.update_attributes(:last_used => 1.year.ago )
            { success: true }
          end
        end
      end
    end


    resource :offline do
      params do
        requires :apikey, type: String, desc: "Api key."
      end
      route_param :apikey do
        post do
          website = Website.find_by_api_key(params[:apikey])
          to = website.settings(:offline).email
          from    = params[:email]
          message = params[:message]
          name    = params[:name]
          url     = website.url
          if website
            WidgetMailer.delay.offline_form(to, name, from, message, url)
            {status: "success"}
          else
            {status: "Api key not found!"}
          end
        end
      end
    end

    resource :post_chat do
      params do
        requires :apikey, type: String, desc: "Api key."
      end
      route_param :apikey do
        post do
          website = Website.find_by_api_key(params[:apikey])
          to = website.settings(:offline).email
          from    = params[:email]
          message = params[:message]
          name    = params[:name]
          if website
            WidgetMailer.delay.post_chat_form(to, name, from, message)
            {status: "success"}
          else
            {status: "Api key not found!"}
          end
        end
      end
    end

    resource :ratings do
      params do
        requires :apikey, type: String, desc: "Api key."
      end
      route_param :apikey do
        get do
          website = Website.find_by_api_key(params[:apikey])
          rating  = Rating.find_by_token(params[:token])
          user    = User.find(params[:aid])

          if rating.blank?
            if params[:up]
              rating = Rating.new(user: user, website: website, up: 1, token: params[:token])
            else
              rating = Rating.new(user: user, website: website, down: 1, token: params[:token])
            end
          else
            if params[:up]
              rating.up = 1
              rating.down = nil
            else
              rating.up = nil
              rating.down = 1
            end
          end

          if website && rating.save
            { status: "success" }
          else
            { status: "Invalid API key." }
          end
        end
      end
    end

  end
end
