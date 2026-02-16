# frozen_string_literal: true

# GraphQL Types

class ServiceType < GraphQL::Schema::Object
  description "A service that can be connected to IFTTT (e.g., Instagram, Dropbox)"

  field :id, ID, null: false
  field :name, String, null: false
  field :slug, String, null: false
  field :icon_url, String
  field :brand_color, String
  field :created_at, GraphQL::Types::ISO8601DateTime, null: false
  field :updated_at, GraphQL::Types::ISO8601DateTime, null: false
end

class AppletType < GraphQL::Schema::Object
  description "An automation that connects a trigger service to an action service"

  field :id, ID, null: false
  field :name, String, null: false
  field :description, String
  field :enabled, Boolean, null: false
  field :trigger_service, ServiceType, null: false
  field :action_service, ServiceType, null: false
  field :created_at, GraphQL::Types::ISO8601DateTime, null: false
  field :updated_at, GraphQL::Types::ISO8601DateTime, null: false
end

# Query Type

class QueryType < GraphQL::Schema::Object
  description "The query root"

  field :applet, AppletType, "Find an applet by ID" do
    argument :id, ID, required: true
  end

  def applet(id:)
    Applet.includes(:trigger_service, :action_service).find(id)
  end

  field :applets, [AppletType], "List all applets" do
    argument :enabled, Boolean, required: false
  end

  def applets(enabled: nil)
    scope = Applet.includes(:trigger_service, :action_service)
    scope = scope.where(enabled: enabled) if enabled.present?
    scope
  end

  field :service, ServiceType, "Find a service by ID" do
    argument :id, ID, required: true
  end

  def service(id:)
    Service.find(id)
  end

  field :services, [ServiceType], "List all services"

  def services
    Service.all
  end
end

# Mutation Type (placeholder for candidates to extend)

class MutationType < GraphQL::Schema::Object
  description "The mutation root"

  field :_dummy, Boolean, null: false, description: "A dummy field to satisfy GraphQL schema requirements" do
    argument :value, Boolean, required: true
  end
  # Candidates can add mutations here
  # Example:
  # field :toggle_applet, AppletType do
  #   argument :id, ID, required: true
  # end
  #
  # def toggle_applet(id:)
  #   applet = Applet.find(id)
  #   applet.update!(enabled: !applet.enabled)
  #   applet
  # end
end

# Schema

class Schema < GraphQL::Schema
  query QueryType
  mutation MutationType

  # For batch-loading (see https://graphql-ruby.org/dataloader/overview.html)
  use GraphQL::Dataloader

  # GraphQL-Ruby validates argument nullability
  validate_max_errors(100)

  # Error handling
  rescue_from(ActiveRecord::RecordNotFound) do |err, obj, args, ctx, field|
    raise GraphQL::ExecutionError, "#{field.type.unwrap.graphql_name} not found"
  end
end
