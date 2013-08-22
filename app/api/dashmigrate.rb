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
          "id":"45", "email":"test@owner52.com", "first_name":"tomas", "last_name":"samot"
        },
        "websites":
        [
          {"name":"adidas.com", "url":"http://www.adidas.com",
            "agents":
            [
              {"first_name":"agent001", "last_name":"agent001", "display_name":"Support", "email":"agent51@test.com", "role":"3"},
              {"first_name":"agent002", "last_name":"agent002", "display_name":"Support", "email":"agent52@test.com", "role":"2"}
            ]
          },
          {"name":"nike", "url":"http://www.nike.com",
            "agents":
            [
              {"first_name":"agent003", "last_name":"agent003", "display_name":"Support", "email":"agent53@test.com" , "role":"3"},
              {"first_name":"agent004", "last_name":"agent004", "display_name":"Support", "email":"agent54@test.com", "role":"2"}
            ]
          }
        ]
        }'
        # test = {}
        data   = JSON test
        owner  = data['owner']
        websites = data['websites']

        get do
            user = User.new()
            password                   = Devise.friendly_token[0,8]
            user.password              = password
            user.password_confirmation = password
            user.name                  = "#{owner['first_name']} #{owner['last_name']}"
            user.reset_password_token  = User.reset_password_token
            # user.plan_id               = 4
            # user.plan_identifier       = "BUSINESS"
            user.email                 = owner['email']
            user.display_name          = owner['display_name'] || "Support"

            if user.save
              #send email
              UserMailer.delay.migrate_owner(user.email, password, user.reset_password_token)

              #create websites
              websites.each do | key, val |
                web = Website.new(
                  :name => key['name'],
                  :url => key['url'],
                  :owner => user
                )

                if web.save
                  allagents = key['agents']
                  allagents.each do | akey, aval |
                    agent_info = {
                      :name => "#{akey['first_name']} #{akey['last_name']}",
                      :email => akey['email']

                    }
                    accounts = []
                    accounts.push(
                      is_admin: (akey[:role] == 2),
                      website_id: web.id,
                      account_id: web.accounts.last.id,
                      role: akey[:role]
                    )
                  User.migration_agents(user, agent_info, accounts)
                  end
                else
                  return  {status: "error on creating website #{key['name']}"}
                end
              end
              return {status: "success", token: user.reset_password_token}
            else
              return {status: "error"}
            end



        end

    end

  end
end
