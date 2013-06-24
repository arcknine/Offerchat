Dashboard::Application.routes.draw do
  get "users/index"
  devise_for :users

  resource :profiles
  resource :users
end
