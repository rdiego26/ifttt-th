Rails.application.routes.draw do
  # GraphQL endpoint
  post "/graphql", to: "graphql#execute"

  # GraphiQL interface (development only)
  if Rails.env.development?
    mount GraphiQL::Rails::Engine, at: "/graphiql", graphql_path: "/graphql"
  end

  # Applets
  resources :applets, only: [:show]

  # Root route
  root "home#index"

  # Health check
  get "up" => "rails/health#show", as: :rails_health_check
end
