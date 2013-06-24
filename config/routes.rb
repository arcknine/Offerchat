Dashboard::Application.routes.draw do
  resource :profiles
  resource :users

  devise_for :users, :controllers => {
    :registrations => "registrations"
  }

  match 'users/sign_in' => redirect('/login')
  match 'users/sign_out' => redirect('/logout')
  match 'users/password/new' => redirect('/forgot')

  as :user do
    match '/user/confirmation' => 'confirmations#update', :via => :put, :as => :update_user_confirmation
    get "/login" => "devise/sessions#new"
    post "/login" => "devise/sessions#create"
    get "/signup" => "devise/registrations#new"
    post "/signup" => "devise/registrations#create"
    match "/forgot" => "devise/passwords#new"
    match "/logout" => "devise/sessions#destroy"
  end

  resources :signup_wizard
  # post 'signup_wizard/step_one' ,:controller => :signup_wizard, :action => 'create'
  # post 'signup_wizard/step_three' ,:controller => :signup_wizard, :action => 'create'

  root :to => 'home#index'

  resource :profiles
end
