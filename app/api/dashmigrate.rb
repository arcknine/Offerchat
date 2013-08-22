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
          "id":"45", "email":"test@owner62.com", "firstname":"tomas", "lastname":"samot"
        },
        "websites":
        [
          {"name":"adidas.com", "url":"http://www.adidas.com",
            "agents":
            [
              {"firstname":"agent001", "lastname":"agent001", "display_name":"Support", "email":"agent61@test.com", "role":"3"},
              {"firstname":"agent002", "lastname":"agent002", "display_name":"Support", "email":"agent62@test.com", "role":"2"}
            ]
          },
          {"name":"nike", "url":"http://www.nike.com",
            "agents":
            [
              {"firstname":"agent003", "lastname":"agent003", "display_name":"Support", "email":"agent63@test.com" , "role":"3"},
              {"firstname":"agent004", "lastname":"agent004", "display_name":"Support", "email":"agent64@test.com", "role":"2"}
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
            user.name                  = "#{owner['firstname']} #{owner['lastname']}"
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
                      :name => "#{akey['firstname']} #{akey['lastname']}",
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
