Dashboard::Application.routes.draw do
  devise_for :users
  resource :profiles
end
