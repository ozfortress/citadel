Rails.application.routes.draw do
  match '/404', to: 'errors#not_found', via: :all
  match '/500', to: 'errors#internal_server_error', via: :all

  namespace :api do
    namespace :v1 do
      resources :leagues, shallow: true, only: [:index, :show] do
        resources :matches, only: [:index, :show]
        resources :rosters, only: [:index, :show]
      end

      get 'users/steam_id/:id', to: 'users#steam_id'
      resources :users, only: [:show]
      resources :teams, only: [:show]
    end
  end

  root 'pages#home'

  get 'pages/home'
  get 'rules', to: 'pages#rules'
  get 'staff', to: 'pages#staff'
  get 'bans', to: 'pages#bans'
  get 'server_configs', to: 'pages#server_configs'
  get 'book_server', to: 'pages#book_server'
  get 'transfers', to: 'pages#transfers'
  get 'newbie_guide', to: 'pages#newbie_guide'
  get 'community_rules', to: 'pages#community_rules'
  get 'infractions', to: 'pages#infractions'

  get 'admin', to: 'admin#index'
  get 'statistics',  to: 'admin#statistics', as: 'admin_statistics'

  namespace :meta do
    resources :games, except: [:destroy]
    resources :formats, except: [:destroy]
    resources :maps, except: [:destroy]
  end

  resources :leagues do
    patch 'modify', on: :member

    resources :transfers, controller: 'leagues/transfers', only: [:index, :destroy, :update]

    resources :rosters, controller: 'leagues/rosters', except: [:show], shallow: true do
      member do
        get   'review'
        patch 'approve'
        delete 'disband'
        put 'undisband'
      end

      resources :transfers, controller: 'leagues/rosters/transfers', only: [:create]
      resources :comments, controller: 'leagues/rosters/comments', only: [:create]
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

      resources :comms, controller: 'leagues/matches/comms',
                        only: [:create, :edit, :update, :destroy] do
        get :edits, on: :member, as: 'edits_for'
        patch :restore, on: :member
      end

      resources :pick_bans, controller: 'leagues/matches/pick_bans', only: [] do
        member do
          patch 'submit'
          patch 'defer'
        end
      end
    end
  end

  resources :rosters, only: [] do
    resources :transfers, controller: 'leagues/rosters/transfers', only: :destroy

    resources :comments, controller: 'leagues/rosters/comments', only: [:edit, :update, :destroy] do
      get :edits, on: :member, as: 'edits_for'
      patch :restore, on: :member
    end
  end

  resources :teams do
    member do
      get   'recruit'
      patch 'invite'
      patch 'leave'
      patch 'kick'
    end

    resource :invite, controller: 'teams/invite', only: [] do
      post 'accept', on: :member
      delete 'decline', on: :member
    end
  end

  get 'users/steam_id/:id', to: 'steam#show'

  get 'profile',      to: 'users#profile', as: 'profile'
  get 'profile/edit', to: 'users#profile'

  get   'users/logout',            to: 'users#logout',              as: 'logout_user'
  get   'users/names',             to: 'users#names',               as: 'users_names'
  get   'users/confirm/:token',    to: 'users#confirm_email',       as: 'confirm_user_email'
  patch 'users/:user_id/name/:id', to: 'users#handle_name_change',  as: 'handle_user_name'
  resources :users, except: [:destroy] do
    post 'name',  on: :member, to: 'users#request_name_change'

    resources :comments, controller: 'users/comments', only: [:create, :edit, :update, :destroy] do
      get :edits, on: :member, as: 'edits_for'
      patch :restore, on: :member
    end

    resources :bans, controller: 'users/bans', only: [:index, :create, :destroy]
    resource :logs, controller: 'users/logs', only: :show do
      get :alts, on: :collection
    end
  end

  resources :notifications, controller: 'users/notifications', only: [:index, :show, :destroy] do
    delete :clear, on: :collection
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
      patch :isolate, on: :member
      patch :unisolate, on: :member
    end

    resources :threads, except: :index do
      concerns :subscribable
      resources :posts, except: [:show, :new, :index], controller: 'posts' do
        get :edits, on: :member, as: 'edits_for'
      end
    end

    resource :posts, only: [], controller: 'posts' do
      get :search, on: :collection
      get :recent, on: :collection
    end
  end

  devise_for :users, controllers: { omniauth_callbacks: 'users/omniauth_callbacks' }
end
