require 'sidekiq/web'
require 'sidekiq-scheduler/web'

Rails.application.routes.draw do
  devise_for :users, only: []
  devise_for :admin_users, ActiveAdmin::Devise.config

  ActiveAdmin.routes(self)
  mount GraphiQL::Rails::Engine, at: '/graphiql', graphql_path: '/graphql' if Rails.env.development? || Rails.env.staging? || Rails.env.ci?
  authenticate :admin_user do
    mount Sidekiq::Web => '/sidekiq'
  end

  resources :plaid do
    collection do
      get 'link_token'
      post 'public_token'
      get 'institution'
      get 'account'
    end
  end

  resources :persona do
    collection do
      get 'verification_summary'
      post 'initiate_inquiry'
      post 'resume_inquiry'
      post 'event'
    end
  end

  post '/graphql', to: 'graphql#execute'
  post '/vendor/graphql', to: 'graphql#execute'
  post '/set-cookie', to: 'cookie#create'
  post '/signin', to: 'cookie#signin' # Keeping it for backward compatibility
  post '/vendor/signin', to: 'cookie#signin'
  post '/callbacks', to: 'callback#create'
  post '/dwolla/events', to: 'dwolla#event'
  post '/middesk/events', to: 'middesk#event'

  get '/forgot-password', to: redirect('/graphiql'), as: :edit_user_password

  get '/health', to: 'health#ok'

  root to: 'admin/dashboard#index'
end
