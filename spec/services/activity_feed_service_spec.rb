# frozen_string_literal: true

require "rails_helper"

# TODO: Candidates should implement ActivityFeedService and write tests here
#
# Example tests to consider:
# - Service returns activities for a given applet
# - Activities have correct structure (id, status, ran_at, etc.)
# - Updates work correctly
# - Activity data relates to the applet's trigger/action services
# - Different statuses (success, failed, skipped) are generated
#
# RSpec.describe ActivityFeedService do
#   let(:applet) { Applet.first }
#   let(:service) { described_class.new(applet_id: applet.id) }
#
#   describe "#fetch" do
#     it "returns a collection of activities" do
#       activities = service.fetch
#       expect(activities).to be_an(Array)
#     end
#
#     it "returns activities with the correct structure" do
#       activities = service.fetch
#       activity = activities.first
#
#       expect(activity).to respond_to(:id)
#       expect(activity).to respond_to(:status)
#       expect(activity).to respond_to(:ran_at)
#       expect(activity).to respond_to(:trigger_data)
#       expect(activity).to respond_to(:action_data)
#     end
#
#     it "supports updates" do
#       page1 = service.fetch(timestamp: 1.hour.ago.iso8601)
#       page2 = service.fetch(timestamp: Time.current.iso8601)
#
#       expect(page1.map(&:id)).not_to eq(page2.map(&:id))
#     end
#   end
# end
