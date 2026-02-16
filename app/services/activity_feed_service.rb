# frozen_string_literal: true

# ActivityFeedService generates mock activity data for applets
#
# Example usage:
#   service = ActivityFeedService.new(applet_id: 1)
#   activities = service.fetch(page: 1, per_page: 20)
#   activities = service.fetch(since: 1.hour.ago)
#   activities = service.fetch(search: "failed")
#
class ActivityFeedService
  STATUSES = [:success, :failed, :skipped].freeze
  DEFAULT_PER_PAGE = 20
  MAX_PER_PAGE = 100

  # Service-specific trigger events and actions
  SERVICE_TRIGGERS = {
    "instagram" => [
      "New photo posted by you",
      "New photo with specific hashtag",
      "New video posted by you",
      "You're tagged in a photo"
    ],
    "dropbox" => [
      "New file in folder",
      "File shared with you",
      "File updated"
    ],
    "feed" => [
      "New feed item",
      "New feed item matches",
      "Feed updated"
    ],
    "gmail" => [
      "New email received",
      "New email from sender",
      "New email with label",
      "New email matching search"
    ],
    "wordpress" => [
      "New post published",
      "Post updated",
      "New comment received"
    ],
    "twitter" => [
      "New tweet by you",
      "New tweet from search",
      "New follower",
      "You're mentioned"
    ],
    "spotify" => [
      "New saved track",
      "New playlist created",
      "Track added to playlist"
    ],
    "google_sheets" => [
      "New row added",
      "Row updated",
      "Cell updated"
    ],
    "ios_photos" => [
      "New photo taken",
      "New screenshot",
      "New photo in album"
    ],
    "google_drive" => [
      "New file in folder",
      "File shared with you",
      "File updated"
    ]
  }.freeze

  SERVICE_ACTIONS = {
    "instagram" => [
      "Posted photo",
      "Added photo to collection",
      "Liked photo"
    ],
    "dropbox" => [
      "Uploaded file: {{filename}}",
      "Created text file: {{filename}}",
      "Moved file to folder"
    ],
    "gmail" => [
      "Sent email to {{email}}",
      "Created draft email",
      "Added label to email"
    ],
    "wordpress" => [
      "Created post: {{title}}",
      "Updated post",
      "Added tag to post"
    ],
    "twitter" => [
      "Posted tweet: {{text}}",
      "Retweeted",
      "Liked tweet"
    ],
    "spotify" => [
      "Saved track: {{track}}",
      "Added to playlist",
      "Created playlist"
    ],
    "google_sheets" => [
      "Added row to spreadsheet",
      "Updated cell in {{sheet}}",
      "Created new sheet"
    ],
    "ios_photos" => [
      "Saved photo to album",
      "Shared photo",
      "Deleted photo"
    ],
    "google_drive" => [
      "Uploaded file: {{filename}}",
      "Created folder",
      "Shared file with {{email}}"
    ]
  }.freeze

  ERROR_MESSAGES = [
    "Authentication failed - please reconnect your account",
    "Rate limit exceeded - waiting to retry",
    "Service temporarily unavailable",
    "Invalid credentials",
    "Network timeout",
    "File not found",
    "Permission denied",
    "Quota exceeded",
    "Invalid request format"
  ].freeze

  attr_reader :applet_id, :applet

  def initialize(applet_id:)
    @applet_id = applet_id
    @applet = Applet.includes(:trigger_service, :action_service).find(applet_id)
  rescue ActiveRecord::RecordNotFound
    raise ArgumentError, "Applet with id #{applet_id} not found"
  end

  # Fetch activities with optional filters
  #
  # @param page [Integer] Page number (1-based)
  # @param per_page [Integer] Number of items per page (default: 20, max: 100)
  # @param since [DateTime, String] Fetch activities since this timestamp
  # @param before [DateTime, String] Fetch activities before this timestamp
  # @param search [String] Search term to filter activities (searches in trigger/action data and errors)
  # @param status [Symbol, String] Filter by status (:success, :failed, :skipped)
  # @return [Array<Activity>] Array of Activity objects
  def fetch(page: 1, per_page: DEFAULT_PER_PAGE, since: nil, before: nil, search: nil, status: nil)
    page = [page.to_i, 1].max
    per_page = [[per_page.to_i, MAX_PER_PAGE].min, 1].max

    # Generate a consistent set of activities based on applet_id and time window
    activities = generate_activities(since: since, before: before)

    # Apply filters
    activities = filter_by_status(activities, status) if status.present?
    activities = filter_by_search(activities, search) if search.present?

    # Apply pagination
    offset = (page - 1) * per_page
    activities[offset, per_page] || []
  end

  # Fetch the latest activities since a given timestamp
  # Useful for polling for new activities
  #
  # @param timestamp [DateTime, String] Fetch activities since this timestamp
  # @param limit [Integer] Maximum number of activities to return
  # @return [Array<Activity>] Array of Activity objects
  def fetch_since(timestamp:, limit: DEFAULT_PER_PAGE)
    fetch(since: timestamp, per_page: limit, page: 1)
  end

  # Get total count of activities (for pagination)
  #
  # @param since [DateTime, String] Count activities since this timestamp
  # @param before [DateTime, String] Count activities before this timestamp
  # @param search [String] Search term
  # @param status [Symbol, String] Filter by status
  # @return [Integer] Total count
  def count(since: nil, before: nil, search: nil, status: nil)
    activities = generate_activities(since: since, before: before)
    activities = filter_by_status(activities, status) if status.present?
    activities = filter_by_search(activities, search) if search.present?
    activities.size
  end

  private

  def generate_activities(since: nil, before: nil)
    # Parse timestamps
    since_time = parse_timestamp(since) || 30.days.ago
    before_time = parse_timestamp(before) || Time.current

    activities = []

    # Generate a deterministic random seed based on applet_id
    rng = Random.new(applet_id)

    # Generate activities at varying intervals (simulating realistic trigger patterns)
    current_time = before_time
    activity_count = 0
    max_activities = 200 # Reasonable limit for mock data

    while current_time > since_time && activity_count < max_activities
      # Random interval between activities (between 5 minutes and 6 hours)
      interval_minutes = rng.rand(5..360)
      current_time -= interval_minutes.minutes

      break if current_time < since_time

      activities << generate_activity(current_time, rng)
      activity_count += 1
    end

    activities.sort_by(&:ran_at).reverse
  end

  def generate_activity(timestamp, rng)
    status = weighted_random_status(rng)

    Activity.new(
      id: generate_deterministic_uuid(applet_id, timestamp),
      applet_id: applet_id,
      status: status,
      ran_at: timestamp,
      trigger_data: generate_trigger_data(rng),
      action_data: generate_action_data(rng, status),
      error_message: status == :failed ? ERROR_MESSAGES.sample(random: rng) : nil
    )
  end

  def generate_trigger_data(rng)
    trigger_service = applet.trigger_service
    events = SERVICE_TRIGGERS[trigger_service.slug] || ["Trigger event occurred"]

    {
      service: trigger_service.name,
      event: events.sample(random: rng),
      details: generate_trigger_details(trigger_service.slug, rng)
    }
  end

  def generate_action_data(rng, status)
    action_service = applet.action_service
    actions = SERVICE_ACTIONS[action_service.slug] || ["Action completed"]

    action_text = actions.sample(random: rng)
    action_text = interpolate_action_text(action_text, action_service.slug, rng)

    {
      service: action_service.name,
      result: status == :skipped ? "Skipped - conditions not met" : action_text,
      completed: status == :success
    }
  end

  def generate_trigger_details(service_slug, rng)
    case service_slug
    when "instagram"
      { photo_id: rng.rand(1000000..9999999).to_s, caption: generate_caption(rng) }
    when "feed"
      { title: generate_feed_title(rng), url: "https://example.com/article-#{rng.rand(1..1000)}" }
    when "gmail"
      { from: generate_email(rng), subject: generate_email_subject(rng) }
    when "wordpress"
      { post_title: generate_blog_title(rng), url: "https://blog.example.com/#{rng.rand(1..1000)}" }
    when "twitter"
      { tweet_text: generate_tweet(rng), username: generate_username(rng) }
    when "spotify"
      { track: generate_track_name(rng), artist: generate_artist_name(rng) }
    when "ios_photos"
      { photo_id: "IMG_#{rng.rand(1000..9999)}.jpg", taken_at: Time.current.iso8601 }
    else
      { data: "Trigger data" }
    end
  end

  def interpolate_action_text(text, service_slug, rng)
    text = text.gsub("{{filename}}", generate_filename(rng)) if text.include?("{{filename}}")
    text = text.gsub("{{email}}", generate_email(rng)) if text.include?("{{email}}")
    text = text.gsub("{{title}}", generate_blog_title(rng)) if text.include?("{{title}}")
    text = text.gsub("{{text}}", generate_tweet(rng)[0..50]) if text.include?("{{text}}")
    text = text.gsub("{{track}}", generate_track_name(rng)) if text.include?("{{track}}")
    text = text.gsub("{{sheet}}", "Sheet#{rng.rand(1..5)}") if text.include?("{{sheet}}")
    text
  end

  # Generate realistic mock data
  def generate_caption(rng)
    captions = [
      "Beautiful sunset today! 🌅",
      "Amazing view from the top! 🏔️",
      "Loving this moment ❤️",
      "Good vibes only ✨",
      "Adventure awaits! 🌍"
    ]
    captions.sample(random: rng)
  end

  def generate_feed_title(rng)
    titles = [
      "New Features in Ruby on Rails 8.0",
      "10 Tips for Better Code Reviews",
      "Understanding GraphQL Schema Design",
      "The Future of Web Development",
      "Building Scalable APIs with Ruby"
    ]
    titles.sample(random: rng)
  end

  def generate_email(rng)
    names = ["john", "sarah", "mike", "emma", "alex"]
    domains = ["gmail.com", "example.com", "company.com"]
    "#{names.sample(random: rng)}.#{rng.rand(100..999)}@#{domains.sample(random: rng)}"
  end

  def generate_email_subject(rng)
    subjects = [
      "Weekly Newsletter",
      "Important Update",
      "Meeting Reminder",
      "Your Order Has Shipped",
      "New Comment on Your Post"
    ]
    subjects.sample(random: rng)
  end

  def generate_blog_title(rng)
    titles = [
      "Getting Started with React Hooks",
      "My Journey Learning Ruby",
      "10 Must-Have VS Code Extensions",
      "Building a REST API from Scratch",
      "Why I Switched to TypeScript"
    ]
    titles.sample(random: rng)
  end

  def generate_tweet(rng)
    tweets = [
      "Just deployed a new feature! 🚀 #webdev #coding",
      "Learning something new every day 💡",
      "Great article on software architecture",
      "Coffee + Code = Perfect morning ☕️",
      "Excited about this new project! 🎉"
    ]
    tweets.sample(random: rng)
  end

  def generate_username(rng)
    "@user#{rng.rand(100..999)}"
  end

  def generate_track_name(rng)
    tracks = [
      "Bohemian Rhapsody",
      "Imagine",
      "Stairway to Heaven",
      "Sweet Child O' Mine",
      "Billie Jean"
    ]
    tracks.sample(random: rng)
  end

  def generate_artist_name(rng)
    artists = [
      "Queen",
      "John Lennon",
      "Led Zeppelin",
      "Guns N' Roses",
      "Michael Jackson"
    ]
    artists.sample(random: rng)
  end

  def generate_filename(rng)
    extensions = ["jpg", "png", "pdf", "docx", "txt"]
    "file_#{rng.rand(1000..9999)}.#{extensions.sample(random: rng)}"
  end

  # Weighted random status (success is more common)
  def weighted_random_status(rng)
    rand_val = rng.rand(100)
    case rand_val
    when 0..79   # 80% success
      :success
    when 80..89  # 10% failed
      :failed
    else         # 10% skipped
      :skipped
    end
  end

  def generate_deterministic_uuid(applet_id, timestamp)
    # Generate a deterministic UUID based on applet_id and timestamp
    require "digest"
    hash = Digest::SHA256.hexdigest("#{applet_id}-#{timestamp.to_i}")
    # Format as UUID v4
    "#{hash[0..7]}-#{hash[8..11]}-#{hash[12..15]}-#{hash[16..19]}-#{hash[20..31]}"
  end

  def parse_timestamp(value)
    return nil if value.nil?
    return value if value.is_a?(Time) || value.is_a?(DateTime)

    Time.zone.parse(value.to_s)
  rescue ArgumentError
    nil
  end

  def filter_by_status(activities, status)
    status_sym = status.to_sym
    return activities unless STATUSES.include?(status_sym)

    activities.select { |activity| activity.status == status_sym }
  end

  def filter_by_search(activities, search)
    return activities if search.blank?

    search_term = search.downcase

    activities.select do |activity|
      # Search in trigger data
      trigger_match = activity.trigger_data.values.any? do |value|
        value.to_s.downcase.include?(search_term)
      end

      # Search in action data
      action_match = activity.action_data.values.any? do |value|
        value.to_s.downcase.include?(search_term)
      end

      # Search in error message
      error_match = activity.error_message&.downcase&.include?(search_term)

      # Search in status
      status_match = activity.status.to_s.downcase.include?(search_term)

      trigger_match || action_match || error_match || status_match
    end
  end
end

