# frozen_string_literal: true

# GraphQL Types

# Simple class to hold activity connection data without ostruct dependency
class ActivityConnection
  attr_reader :activities, :total_count, :page, :per_page, :total_pages

  def initialize(activities:, total_count:, page:, per_page:, total_pages:)
    @activities = activities
    @total_count = total_count
    @page = page
    @per_page = per_page
    @total_pages = total_pages
  end
end

# JSON scalar type for flexible data structures
class JSONType < GraphQL::Schema::Scalar
  description "A valid JSON value"

  def self.coerce_input(value, _ctx)
    value
  end

  def self.coerce_result(value, _ctx)
    value
  end
end

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

class ActivityType < GraphQL::Schema::Object
  description "An activity record representing a single execution of an applet"

  field :id, String, null: false, description: "Unique identifier for this activity"
  field :applet_id, ID, null: false, description: "ID of the applet that generated this activity"
  field :status, String, null: false, description: "Status of the activity (success, failed, skipped)"
  field :ran_at, GraphQL::Types::ISO8601DateTime, null: false, description: "When the activity was executed"
  field :trigger_data, JSONType, null: false, description: "Data about what triggered the activity"
  field :action_data, JSONType, null: false, description: "Data about the action that was performed"
  field :error_message, String, null: true, description: "Error message if the activity failed"

  # Helper methods to expose the data
  def trigger_data
    object.trigger_data
  end

  def action_data
    object.action_data
  end
end

class ActivityConnectionType < GraphQL::Schema::Object
  description "Paginated list of activities"

  field :activities, [ActivityType], null: false, description: "List of activities"
  field :total_count, Integer, null: false, description: "Total number of activities matching the filters"
  field :page, Integer, null: false, description: "Current page number"
  field :per_page, Integer, null: false, description: "Number of items per page"
  field :total_pages, Integer, null: false, description: "Total number of pages"
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

  field :activities, ActivityConnectionType,
        "Get activities for an applet with pagination and filters",
        null: false,
        connection: false do
    argument :applet_id, ID, required: true, description: "ID of the applet"
    argument :page, Integer, required: false, default_value: 1, description: "Page number (1-based)"
    argument :per_page, Integer, required: false, default_value: 20, description: "Number of items per page"
    argument :since_time, GraphQL::Types::ISO8601DateTime, required: false, description: "Fetch activities since this timestamp"
    argument :before_time, GraphQL::Types::ISO8601DateTime, required: false, description: "Fetch activities before this timestamp"
    argument :status, String, required: false, description: "Filter by status (success, failed, skipped)"
    argument :search, String, required: false, description: "Search term to filter activities"
  end

  def activities(applet_id:, page: 1, per_page: 20, since_time: nil, before_time: nil, status: nil, search: nil)
    service = ActivityFeedService.new(applet_id: applet_id)

    activities = service.fetch(
      page: page,
      per_page: per_page,
      since: since_time,
      before: before_time,
      status: status,
      search: search
    )

    total_count = service.count(
      since: since_time,
      before: before_time,
      status: status,
      search: search
    )

    total_pages = (total_count.to_f / per_page).ceil

    ActivityConnection.new(
      activities: activities,
      total_count: total_count,
      page: page,
      per_page: per_page,
      total_pages: total_pages
    )
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
