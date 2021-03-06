module Stats
  class API < Grape::API
    version 'v1', using: :header, vendor: 'offerchat'
    format :json

    helpers do
      def authenticate(key)
        error!('401 Unauthorized', 401) unless key == "0ff3rch@t"
      end
    end

    resource :updates do
      desc "Insert an update. Format: { :key => '0ff3rch@t', :stats => [ { :website_id => 1, :user_id => 1, :active => 1, :missed => 1, :proactive => 1 }, { :website_id .... } ] }"
      params do
        requires :key, type: String, desc: "API Key"
      end

      post do
        authenticate(params[:key])
        stats = JSON.parse(params[:stats])
        stats.each do |s|
          Stat.create({ website_id: s['website_id'], user_id: s['user_id'], active: s['active'], missed: s['missed'], proactive: s['proactive'] })
        end
      end
    end
  end
end


