DigitalMediaCenter::Application.routes.draw do

  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)
  devise_for :users, controllers: {
    sessions: 'sessions',
    confirmations: 'confirmations',
    registrations: 'registrations'
  }
  mount Sidekiq::Web => '/sidekiq'

  namespace :api do
    namespace :v1 do
      resources :tokens, path: 'token', only: :create
      resources :user_tokens, path: 'user_token', only: :create
      #get 'auth', to: 'authorizations#new'

      resources :folders, only: :index

      resources :galleries, only: :index

      resources :assets, only: :index do
        member do
          get :manifest
        end
      end

      resources :invites, only: :create do
        delete '/', to: :destroy, on: :collection
      end

      match '*unmatched_route' => 'base#wrong_url', via: [:get, :post, :put, :delete]
    end
  end

  scope module: :api do
    constraints subdomain: 'api' do
      get '/' => 'demo#index'
      get :console, to: 'demo#console', as: :api_console
    end
  end

  scope module: :frontend do
    constraints(Subdomain) do
      get '/' => "galleries#portal", as: :portal_root
      get '/robots' => 'utils#robots', format: :txt
      resource :authorizations, only: [] do
        post :password, on: :member
      end
      resources :galleries, only: [:index, :show] do
        resource :invitation_request, only: [:new, :create], on: :member, controller: 'invites'
        post :authenticate, on: :member
        resources :folders, only: [] do
          post :authenticate, on: :member
          resources :assets, only: :index do
            get :manifest, on: :member
            get :download, on: :member
          end
        end
      end

      resources :events, only: :create

      resources :announcements, only: :index

      get "/q/:quicklink_hash" => "assets#quicklink", as: :quicklink
      get "/q/:quicklink_hash/download" => "assets#quicklink_download", as: :quicklink_download
      get "/q/:quicklink_hash/manifest" => "assets#quicklink_manifest", as: :quicklink_manifest
      get "/e/:embedding_hash" => "assets#embedded", as: :embedded
      get "/e/:embedding_hash/manifest" => "assets#embedded_manifest", as: :embedded_manifest
    end
  end

  #scope module: :media do
  #  constraints(Subdomain) do
  #    resources :authorizations, only: :create
  #  end
  #end

  concern :manager do
    resources :analytics, only: [:index, :show]

    resources :assets, only: [:create, :destroy] do
      post :update_multiple, on: :collection
      post :generate_quicklink, on: :member
    end

    resources :galleries, except: :new do
      post :toggle_first, on: :member
      post :reorder, on: :collection
      resources :folders, except: [:show, :new, :edit] do
        post :reorder, on: :collection
        resources :assets, only: [:index, :show, :update, :destroy] do
          get :download, on: :member
          put :reorder, on: :collection
          put :sort, on: :collection
          get :manifest, on: :member
        end
      end
    end

    resources :folders, only: :index
  end

  authenticated :user do
    scope module: :backend do
      root to: 'galleries#portal', as: :dashboard
      concerns :manager

      resource :account, only: :update do
        post :retrieve_auth_token

        resources :users, except: [:show] do
          collection do
            get  :members_csv, to: 'users#members_csv', format: 'csv', as: :csv_export
            get  :invite, to: 'users#invite', as: :invite
            post :invite, to: 'users#create_invited', as: :create_invited
          end
        end

        resources :roles, except: [:show]
      end

      resource :profile, only: :update

      resources :downloads, only: :index do
        get :detailed, on: :collection
      end

      resources :authorizations, only: [] do
        member do
          post :approve
          post :decline
        end
      end

      resources :invites, only: [:create, :destroy, :new]

      resources :invitation_requests, only: :destroy

      resources :events, only: :index

      resources :announcements, except: [:show]

      resources :settings, only: [] do
        collection do
          get :analytics
          get :account
          get :security
          get :profile
          get :events_csv, to: 'settings#events_csv', format: 'csv', as: :events_csv_report
          get :downloads_csv, to: 'settings#downloads_csv', format: 'csv', as: :downloads_csv_report
        end
      end

      resources :current_account, only: [] do
        post 'select', on: :member
      end
    end
  end

  #authenticated :media_user do
  #  scope module: :media do
  #    root to: 'authorizations#index', as: :media_dashboard
  #    resources :authorizations, only: [:index, :destroy]
  #  end
  #end
  #
  #resources :media_accounts, path: '/media/accounts'

  resources :blog_posts, path: 'blog', only: [:index, :show]

  post 'callbacks/robot' => "callbacks#robot", as: :robot_callback

  get '/:page' => "static#show", as: :static_page

  root to: "pages#home"
end
