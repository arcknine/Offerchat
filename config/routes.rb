Dashboard::Application.routes.draw do
  resource :profiles do
    collection do
      post "update_avatar"
    end
  end

  resources :agents do
    collection do
      get "only"
    end
  end
  resource :settings
  resources :triggers
  resources :plans do
    collection do
      get "by_name/:id", :action => "by_name"
    end
  end

  resources :subscriptions

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
    end
  end

  resources :signup_wizard
  resource :passwords

  devise_for :admins
  mount RailsAdmin::Engine => '/admins', :as => 'rails_admin'

  require 'sidekiq/web'
  mount Sidekiq::Web => '/sidekiq'

  mount StripeEvent::Engine => '/stripe_webhook'

  root :to => 'home#index'
  resources :transcript, :only => [:show]
  mount Offerchat::API => '/api/v1/widget/'

  mount Dashmigrate::API => '/api/v1/migration/'
end
