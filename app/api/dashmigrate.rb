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
        params do
          requires :user, type: String, desc: "User information from old dashboard."
        end


        get do
            old_data = params[:user]
            data   = JSON old_data
            owner  = data['owner']
            websites = data['websites']

            user = User.new()
            password                   = Devise.friendly_token[0,8]
            user.password              = password
            user.password_confirmation = password
            user.name                  = "#{owner['firstname']} #{owner['lastname']}"
            user.reset_password_token  = User.reset_password_token
            user.plan_identifier       = "PERSONAL"
            user.email                 = owner['email']
            user.display_name          = owner['display_name'] || "Support"

            if user.save
              #send email
              UserMailer.delay.migrate_owner(user.email, password, user.reset_password_token)

              #create websites
              websites.each do | key, val |
                Website.new(
                  :name => key['name'],
                  :url => key['url'],
                  :owner => user
                ).save

                # if web.save
                #   allagents = key['agents']
                #   allagents.each do | akey, aval |
                #     agent_info = {
                #       :name => "#{akey['firstname']} #{akey['lastname']}",
                #       :email => akey['email']

                #     }
                #     accounts = []
                #     accounts.push(
                #       is_admin: (akey[:role] == 2),
                #       website_id: web.id,
                #       account_id: web.accounts.last.id,
                #       role: akey[:role]
                #     )
                #   User.migration_agents(user, agent_info, accounts)
                #   end
                # else
                #   return  {status: "error on creating website #{key['name']}"}
                # end
              end
              return {status: "success", token: user.reset_password_token}
            else
              return {status: "error"}
            end
        end

    end

  end
end
