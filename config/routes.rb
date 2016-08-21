Rails.application.routes.draw do
  mount LetsencryptPlugin::Engine, at: '/'

  root 'pages#home'

  get 'pages/home'

  get 'admin', to: 'admin#index'
  get 'logs',  to: 'admin#logs', as: 'admin_logs'

  namespace :meta do
    resources :games, except: [:destroy]
    resources :formats, except: [:destroy]
    resources :maps, except: [:destroy]
  end

  # TODO: Use simplify routing with member and collection routes for resources

  patch 'leagues/:id/status', to: 'leagues#status', as: 'league_status'
  resources :leagues do
    resources :transfers, controller: 'leagues/transfers', only: [:index, :destroy, :update]

    resources :rosters, controller: 'leagues/rosters' do
      member do
        get   'review'
        patch 'approve'
      end

      resource :transfers, controller: 'leagues/rosters/transfers', only: [:show, :create]
      resource :comments, controller: 'leagues/rosters/comments', only: [:create]
    end

    post  'matches/:id/comms',   to: 'leagues/matches#comms',   as: 'match_comms'
    patch 'matches/:id/scores',  to: 'leagues/matches#scores',  as: 'match_scores'
    patch 'matches/:id/confirm', to: 'leagues/matches#confirm', as: 'match_confirm'
    resources :matches, controller: 'leagues/matches' do
      collection do
        get 'generate'
        post 'generate', action: 'create_round'
      end
      patch 'forfeit', on: :member
    end
  end

  resources :teams do
    member do
      get   'recruit'
      patch 'invite'
      patch 'leave'
      patch 'grant'
      patch 'revoke'
    end
  end

  patch 'team_invites/:id/accept',  to: 'team_invites#accept',  as: 'accept_team_invite'
  patch 'team_invites/:id/decline', to: 'team_invites#decline', as: 'decline_team_invite'

  get   'users/logout',            to: 'users#logout',              as: 'logout_user'
  get   'users/names',             to: 'users#names',               as: 'users_names'
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

  # TODO: fix XSS vuln (wasn't able to style forms as links in navbar)
  get 'notifications/:id', to: 'users/notifications#read', as: 'read_notification'
  delete 'notifications', to: 'users/notifications#clear', as: 'clear_notifications'

  devise_for :users, controllers: { omniauth_callbacks: 'users/omniauth_callbacks' }
end
