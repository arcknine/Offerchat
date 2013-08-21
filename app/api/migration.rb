module Migration
  class API < Grape::API
    use Rack::JSONP
    version 'v1', using: :header, vendor: 'offerchat'
    format :json

    desc "ping pong"
    get :ping do
      { ping: "pong"}
    end

    resource :user do
        test = '{"owner": {"id":"45", "email":"test@sdfasdfsad123.com", "name":"tomas"}, websites": [{"name":"tes.com", "url":"http://www.test.com"},{"name":"test3.com", "url":"http://test3.com"}, agents": [{"name":"Reco", "email":"reyco@test.com"},{"name":"Mark Gamzy", "email":"mark@yahoo.com"}]'

        data   = JSON test
        owner  = data['owner']
        websites = data['websites']
        agents = data['agents']
        get do
            user = User.new(
               :email => owner['email'],
               :password => '123456789',
               :name => owner['name'],
               :display_name => owner['name']
              )

            if user.save
              #send email

              #create websites
              websites.each do | key, val |
                user.websites.new(
                  :name => key['name'],
                  :url => key['url']
                ).save

              end

              #create agents
              agents.each do | key, val |
                user.agents.new(
                  :name => key['name'],
                  :email => key['emal'],
                  :password => '123456789',
                  :display_name => "Support"
                ).save

              end


              {status: "success"}
            else
              {status: "error"}
            end



        end

    end

  end
end
