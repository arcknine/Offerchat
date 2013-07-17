Dashboard::Application.routes.draw do

  resource :profiles
  resources :agents


  resource :settings


  devise_for :users, :path => '', :path_names => {:sign_in => 'login', :sign_out => 'logout'}, :controllers => {
    :registrations => "registrations"
  }




  resources :websites do
    collection do
      get "my_sites"
    end
    member do
      put "update_settings"
    end
  end

  resources :signup_wizard
  resource :passwords

  # post 'signup_wizard/step_one' ,:controller => :signup_wizard, :action => 'create'
  # post 'signup_wizard/step_three' ,:controller => :signup_wizard, :action => 'create'

  root :to => 'home#index'
end
