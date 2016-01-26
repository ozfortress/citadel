Rails.application.routes.draw do
  root 'pages#home'

  get 'pages/home'

  resources :leagues
  resources :teams

  get 'users/logout', to: 'users#logout', as: 'logout_user'
  resources :users

  devise_for :users, controllers: { omniauth_callbacks: 'users/omniauth_callbacks' }
end
