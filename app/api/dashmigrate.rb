module Dashmigrate
  class API < Grape::API
    use Rack::JSONP
    version 'v1', using: :header, vendor: 'offerchat'
    format :json

    desc "ping pong"
    get :ping do
      { ping: "pong"}
    end

    resource :user do
        test = '{
        "owner":
        {
          "id":"45", "email":"test@owner11.com", "name":"tomas"
        },
        "websites":
        [
          {"name":"adidas.com", "url":"http://www.adidas.com",
            "agents":
            [
              {"name":"agent001", "display_name":"Support", "email":"agent11@test.com", "role":"3"},
              {"name":"agent002", "display_name":"Support", "email":"agent12@test.com", "role":"2"}
            ]
          },
          {"name":"nike", "url":"http://www.nike.com",
            "agents":
            [
              {"name":"agent003", "display_name":"Support", "email":"agent13@test.com" , "role":"3"},
              {"name":"agent004", "display_name":"Support", "email":"agent14@test.com", "role":"3"}
            ]
          }
        ]
        }'
        # test = {}
        data   = JSON test
        owner  = data['owner']
        websites = data['websites']
        agents = data['agents']
        get do
            user = User.new()
            password                   = Devise.friendly_token[0,8]
            user.password              = password
            user.password_confirmation = password
            user.name                  = owner['name']
            user.email                 = owner['email']
            user.display_name          = owner['display_name'] || "Support"

            if user.save
              #send email

              #create websites
              websites.each do | key, val |
                web = user.websites.new(
                  :name => key['name'],
                  :url => key['url']
                )

                if web.save
                  allagents = key['agents']
                  allagents.each do | akey, aval |
                    agent_info = {
                      :name => akey['name'],
                      :email => akey['email']
                    }
                    accounts = []
                    accounts.push(
                      is_admin: (akey[:role] == 2),
                      website_id: web.id,
                      account_id: nil,
                      role: akey[:role]
                    )
                    agents = User.migration_create_or_invite_agents(user, agent_info, accounts)
                  end
                  {status: "success"}
                else
                  {status: "error on creating website #{key['name']}"}
                end
              end
            else
              {status: "error"}
            end



        end

    end

  end
end
