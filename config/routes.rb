# config/routes.rb
Rails.application.routes.draw do
  # Enable GraphiQL interface in development
  if Rails.env.development?
    mount GraphiQL::Rails::Engine, at: "/graphiql", graphql_path: "/graphql"
  end

  root "welcome#welcome"

  # GraphQL endpoint
  post "/graphql", to: "graphql#execute"

  # Health check endpoint
  get "up" => "rails/health#show", as: :rails_health_check

  # Optional: Custom export download route (if using manual controller for file download)
  get "/exports/:id", to: "exports#show", as: :download_export

  # REST endpoints for tickets (for completeness, though GraphQL is used)
  resources :tickets, only: [ :create, :index, :show ]

  mount ActiveStorage::Engine => "/rails/active_storage"
end
