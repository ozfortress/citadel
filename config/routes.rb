Rails.application.routes.draw do
  mount LetsencryptPlugin::Engine, at: '/'

  root 'pages#home'

  get 'pages/home'
  get 'rules', to: 'pages#rules'
  get 'staff', to: 'pages#staff'
  get 'server_configs', to: 'pages#server_configs'

  get 'admin', to: 'admin#index'
  get 'logs',  to: 'admin#logs', as: 'admin_logs'

  namespace :meta do
    resources :games, except: [:destroy]
    resources :formats, except: [:destroy]
    resources :maps, except: [:destroy]
  end

  resources :leagues do
    patch 'modify', on: :member

    resources :transfers, controller: 'leagues/transfers', only: [:index, :destroy, :update]

    resources :rosters, controller: 'leagues/rosters', shallow: true do
      member do
        get   'review'
        patch 'approve'
        delete 'disband'
      end

      resource :transfers, controller: 'leagues/rosters/transfers', only: [:create]
      resource :comments, controller: 'leagues/rosters/comments', only: [:create]
    end

    resources :matches, controller: 'leagues/matches', shallow: true do
      collection do
        get 'generate'
        post 'generate', action: 'create_round'
      end

      member do
        patch 'forfeit'
        patch 'submit'
        patch 'confirm'
      end

      resources :comms, controller: 'leagues/matches/comms', only: [:create]
    end
  end

  resources :teams do
    member do
      get   'recruit'
      patch 'invite'
      patch 'leave'
      patch 'kick'
      patch 'grant'
      patch 'revoke'
    end

    resource :invite, controller: 'teams/invite', only: [] do
      post 'accept', on: :member
      delete 'decline', on: :member
    end
  end

  get 'users/steam_id/:id', to: 'steam#show'

  get   'users/logout',            to: 'users#logout',              as: 'logout_user'
  get   'users/names',             to: 'users#names',               as: 'users_names'
  get   'users/confirm/:token',    to: 'users#confirm_email',       as: 'confirm_user_email'
  patch 'users/:user_id/name/:id', to: 'users#handle_name_change',  as: 'handle_user_name'
  resources :users, except: [:destroy] do
    post 'name',  on: :member, to: 'users#request_name_change'
  end

  resources :permissions, only: :index do
    collection do
      get :users
      post :grant
      delete :revoke
    end
  end

  concern :subscribable do
    member do
      patch :toggle_subscription, as: 'toggle_subscription_for'
    end
  end

  resource :forums, only: :show
  namespace :forums, shallow: true do
    resources :topics, except: :index do
      concerns :subscribable
    end

    resources :threads, except: :index do
      concerns :subscribable
      resources :posts, except: [:show, :new, :index], controller: 'posts' do
        get :edits, on: :member, as: 'edits_for'
      end
    end
  end

  # TODO: fix XSS vuln (wasn't able to style forms as links in navbar)
  get 'notifications/:id', to: 'users/notifications#read', as: 'read_notification'
  delete 'notifications', to: 'users/notifications#clear', as: 'clear_notifications'

  devise_for :users, controllers: { omniauth_callbacks: 'users/omniauth_callbacks' }
end
