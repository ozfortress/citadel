Rails.application.routes.draw do
  root 'pages#home'

  get 'pages/home'

  get 'meta', to: 'meta#index'
  namespace :meta do
    resources :games
    resources :formats
  end

  resources :leagues

  patch 'teams/:id/grant', to: 'teams#grant', as: 'grant_team'
  patch 'teams/:id/revoke', to: 'teams#revoke', as: 'revoke_team'
  resources :teams

  # Debug
  patch 'users/grant_meta', to: 'users#grant_meta', as: 'grant_meta'
  patch 'users/revoke_meta', to: 'users#revoke_meta', as: 'revoke_meta'

  get 'users/logout', to: 'users#logout', as: 'logout_user'
  resources :users

  devise_for :users, controllers: { omniauth_callbacks: 'users/omniauth_callbacks' }
end
