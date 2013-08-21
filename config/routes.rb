Dashboard::Application.routes.draw do
  mount RailsAdmin::Engine => '/admin', :as => 'rails_admin'

  resource :profiles do
    collection do
      post "update_avatar"
    end
  end

  resources :agents
  resource :settings
  resources :triggers
  resources :plans
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


  require 'sidekiq/web'
  mount Sidekiq::Web => '/sidekiq'

  mount StripeEvent::Engine => '/stripe_webhook'

  root :to => 'home#index'
  resources :exporters
  mount Offerchat::API => '/api/v1/widget/'
  # mount Migration::API => '/api/v1/migration/'

end
