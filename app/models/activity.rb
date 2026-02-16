# Activity is generated at runtime, not stored in the database
#
# Example usage:
#   activity = Activity.new(
#     id: SecureRandom.uuid,
#     applet_id: 1,
#     status: :success,
#     ran_at: Time.current,
#     trigger_data: { service: "Instagram", event: "New photo posted" },
#     action_data: { service: "Dropbox", result: "Uploaded photo.jpg" },
#     error_message: nil
#   )

Activity = Struct.new(
  :id,            # UUID string
  :applet_id,     # Integer - references Applet
  :status,        # Symbol - :success, :failed, or :skipped
  :ran_at,        # DateTime - when the activity ran
  :trigger_data,  # Hash - { service: String, event: String }
  :action_data,   # Hash - { service: String, result: String }
  :error_message, # String or nil - error message if failed
  keyword_init: true
) do
  def success?
    status == :success
  end

  def failed?
    status == :failed
  end

  def skipped?
    status == :skipped
  end

  def to_h
    {
      id: id,
      applet_id: applet_id,
      status: status.to_s,
      ran_at: ran_at.iso8601,
      trigger_data: trigger_data,
      action_data: action_data,
      error_message: error_message
    }
  end
end
