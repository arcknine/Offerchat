Dashboard::Application.routes.draw do
  resource :profiles do
    collection do
      post "update_avatar"
    end
  end

  resources :agents do
    collection do
      get "only"
      get "manage_agents"
    end
  end

  resources :reports, :only => [:index]  do
    collection do
      post "ratings"
      post "stats"
    end
  end

  resource :settings
  resources :triggers

  resources :visitors do
    member do
      get "notes"
      post "update_info"
    end
  end

  resources :plans do
    collection do
      get "by_name/:id", :action => "by_name"
    end
  end

  resources :coupons do
    collection do
      get "retrieve"
    end
  end

  resources :attention_grabbers

  resources :subscriptions

  resources :quick_responses
  resources :visitor_notes

  resources :getting_started
  resources :widget_codes

  devise_for :users, :path => '', :path_names => {:sign_in => 'login', :sign_out => 'logout'}, :controllers => {
    :registrations => "registrations"
  }

  resources :websites do
    collection do
      get "owned"
      get "managed"
      post "webmaster_code"
    end
    member do
      put "update_settings"
      get "triggers"
      post "update_attention_grabber"
      post "zendesk_auth"
    end
  end

  resources :signup_wizard
  resource :passwords

  devise_for :admins
  mount RailsAdmin::Engine => '/admins', :as => 'rails_admin'

  require 'sidekiq/web'
  Sidekiq::Web.use Rack::Auth::Basic do |username, password|
    username == 'admin' && password == '0ff3rch@t'
  end
  mount Sidekiq::Web => '/sidekiq'

  mount StripeEvent::Engine => '/stripe_webhook'

  root :to => 'home#index'
  get "/touch/:id" => "agents#touch"
  # resources :transcript, :only => [:show]
  resources :transcript do
    collection do
      post "email_export"
    end
  end

  mount Offerchat::API => '/api/v1/widget/'

  mount Dashmigrate::API => '/api/v1/migration/'

  mount Stats::API => '/api/v1/stats/'
end
