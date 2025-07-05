require "sidekiq/web"
require "sidekiq-scheduler/web"

Rails.application.routes.draw do
  Rails.application.routes.default_url_options[:host] = "localhost:3000"

  # Enable GraphiQL in development
  if Rails.env.development?
    mount GraphiQL::Rails::Engine, at: "/graphiql", graphql_path: "/graphql"
    mount Sidekiq::Web => "/sidekiq" # 👈 after sessions are enabled
  end

  root "welcome#welcome"

  post "/graphql", to: "graphql#execute"
  get "up" => "rails/health#show", as: :rails_health_check
  get "/exports/:id", to: "exports#show", as: :download_export
  resources :tickets, only: [ :create, :index, :show ]
  mount ActiveStorage::Engine => "/rails/active_storage"
end
