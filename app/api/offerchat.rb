module Offerchat
  class API < Grape::API

    version 'v1', using: :header, vendor: 'offerchat'
    format :json


    resource :settings do

      desc "Hello World"
      get :hello do
        {hello: "world"}
      end

    end

    resource :widget do
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

      resource :token do
        params do
          requires :apikey, type: String, desc: "Api key."
        end
        route_param :apikey do
          get do
            # visitor = Visitor.new
            website = Website.find_by_api_key(params[:apikey])
            visitor = website.visitors.new()
            if visitor.save
              {token: visitor.token}
            else
              {error: "Invalid token request!"}
            end


          end
        end
      end

    end

  end
end
