# frozen_string_literal: true

require "rails_helper"

RSpec.describe ActivityFeedService do
  let(:trigger_service) do
    Service.find_or_create_by!(slug: "instagram") do |s|
      s.name = "Instagram"
      s.icon_url = "https://example.com/instagram.png"
      s.brand_color = "#E1306C"
    end
  end
  let(:action_service) do
    Service.find_or_create_by!(slug: "dropbox") do |s|
      s.name = "Dropbox"
      s.icon_url = "https://example.com/dropbox.png"
      s.brand_color = "#0061FF"
    end
  end
  let(:applet) do
    create(:applet,
      name: "Save Instagram photos to Dropbox",
      trigger_service: trigger_service,
      action_service: action_service)
  end
  let(:service) { described_class.new(applet_id: applet.id) }

  describe "#initialize" do
    it "initializes with a valid applet_id" do
      expect(service.applet_id).to eq(applet.id)
      expect(service.applet).to eq(applet)
    end

    it "raises an error with an invalid applet_id" do
      expect do
        described_class.new(applet_id: 999_999)
      end.to raise_error(ArgumentError, /Applet with id 999999 not found/)
    end
  end

  describe "#fetch" do
    it "returns a collection of activities" do
      activities = service.fetch
      expect(activities).to be_an(Array)
      expect(activities).not_to be_empty
    end

    it "returns activities with the correct structure" do
      activities = service.fetch
      activity = activities.first

      expect(activity).to be_a(Activity)
      expect(activity.id).to be_present
      expect(activity.applet_id).to eq(applet.id)
      expect(activity.status).to be_in([:success, :failed, :skipped])
      expect(activity.ran_at).to be_a(Time)
      expect(activity.trigger_data).to be_a(Hash)
      expect(activity.action_data).to be_a(Hash)
    end

    it "returns activities with trigger data related to the applet's trigger service" do
      activities = service.fetch
      activity = activities.first

      expect(activity.trigger_data[:service]).to eq(trigger_service.name)
      expect(activity.trigger_data[:event]).to be_present
    end

    it "returns activities with action data related to the applet's action service" do
      activities = service.fetch
      activity = activities.first

      expect(activity.action_data[:service]).to eq(action_service.name)
      expect(activity.action_data[:result]).to be_present
    end

    it "includes error messages for failed activities" do
      activities = service.fetch
      failed_activity = activities.find { |a| a.status == :failed }

      # Might not have failed activities in a small sample, so we'll check if we find one
      if failed_activity
        expect(failed_activity.error_message).to be_present
      end
    end

    it "does not include error messages for successful activities" do
      activities = service.fetch
      successful_activity = activities.find { |a| a.status == :success }

      if successful_activity
        expect(successful_activity.error_message).to be_nil
      end
    end

    it "generates different statuses (success, failed, skipped)" do
      activities = service.fetch(per_page: 50)
      statuses = activities.map(&:status).uniq

      # With 50 activities, we should have multiple statuses
      expect(statuses.length).to be > 1
    end

    it "returns activities sorted by ran_at in descending order (newest first)" do
      activities = service.fetch
      timestamps = activities.map(&:ran_at)

      expect(timestamps).to eq(timestamps.sort.reverse)
    end

    context "with pagination" do
      it "supports page parameter" do
        page1 = service.fetch(page: 1, per_page: 10)
        page2 = service.fetch(page: 2, per_page: 10)

        expect(page1.size).to eq(10)
        expect(page2.size).to eq(10)
        expect(page1.map(&:id)).not_to eq(page2.map(&:id))
      end

      it "respects per_page parameter" do
        activities = service.fetch(per_page: 5)
        expect(activities.size).to eq(5)
      end

      it "limits per_page to MAX_PER_PAGE" do
        activities = service.fetch(per_page: 200)
        expect(activities.size).to be <= ActivityFeedService::MAX_PER_PAGE
      end

      it "defaults to DEFAULT_PER_PAGE when per_page not specified" do
        activities = service.fetch
        expect(activities.size).to eq(ActivityFeedService::DEFAULT_PER_PAGE)
      end
    end

    context "with time-based filters" do
      it "supports since parameter" do
        since_time = 1.hour.ago
        activities = service.fetch(since: since_time)

        activities.each do |activity|
          expect(activity.ran_at).to be >= since_time
        end
      end

      it "supports before parameter" do
        before_time = 1.day.ago
        activities = service.fetch(before: before_time)

        activities.each do |activity|
          expect(activity.ran_at).to be <= before_time
        end
      end

      it "supports both since and before parameters" do
        since_time = 5.days.ago
        before_time = 2.days.ago
        activities = service.fetch(since: since_time, before: before_time)

        activities.each do |activity|
          expect(activity.ran_at).to be_between(since_time, before_time)
        end
      end

      it "handles ISO8601 timestamp strings" do
        since_time = 2.hours.ago.iso8601
        activities = service.fetch(since: since_time)

        expect(activities).to be_an(Array)
      end
    end

    context "with status filter" do
      it "filters by success status" do
        activities = service.fetch(status: :success, per_page: 50)
        expect(activities.all? { |a| a.status == :success }).to be true
      end

      it "filters by failed status" do
        activities = service.fetch(status: :failed, per_page: 50)
        expect(activities.all? { |a| a.status == :failed }).to be true
      end

      it "filters by skipped status" do
        activities = service.fetch(status: :skipped, per_page: 50)
        expect(activities.all? { |a| a.status == :skipped }).to be true
      end

      it "accepts status as string" do
        activities = service.fetch(status: "success", per_page: 50)
        expect(activities.all? { |a| a.status == :success }).to be true
      end
    end

    context "with search filter" do
      it "searches in trigger data" do
        # We know Instagram service generates photo-related triggers
        activities = service.fetch(search: "photo", per_page: 50)

        # At least some activities should match
        expect(activities).not_to be_empty
      end

      it "searches in action data" do
        # Dropbox service generates file upload actions
        activities = service.fetch(search: "file", per_page: 50)

        expect(activities).not_to be_empty
      end

      it "searches in error messages" do
        activities = service.fetch(search: "authentication", per_page: 50)

        # Should find activities with authentication-related errors
        if activities.any?
          expect(activities.any? { |a| a.error_message&.downcase&.include?("authentication") }).to be true
        end
      end

      it "searches in status" do
        activities = service.fetch(search: "failed", per_page: 50)

        expect(activities.all? { |a| a.status == :failed }).to be true
      end

      it "is case insensitive" do
        activities_lower = service.fetch(search: "photo", per_page: 50)
        activities_upper = service.fetch(search: "PHOTO", per_page: 50)

        expect(activities_lower.map(&:id)).to eq(activities_upper.map(&:id))
      end
    end

    context "with combined filters" do
      it "supports pagination with status filter" do
        activities = service.fetch(page: 1, per_page: 10, status: :success)

        expect(activities.size).to be <= 10
        expect(activities.all? { |a| a.status == :success }).to be true
      end

      it "supports search with status filter" do
        activities = service.fetch(search: "photo", status: :success, per_page: 50)

        expect(activities.all? { |a| a.status == :success }).to be true
      end

      it "supports time range with search" do
        activities = service.fetch(
          since: 5.days.ago,
          before: 1.day.ago,
          search: "photo",
          per_page: 50
        )

        activities.each do |activity|
          expect(activity.ran_at).to be_between(5.days.ago, 1.day.ago)
        end
      end
    end
  end

  describe "#fetch_since" do
    it "fetches activities since a given timestamp" do
      timestamp = 2.hours.ago
      activities = service.fetch_since(timestamp: timestamp)

      expect(activities).to be_an(Array)
      activities.each do |activity|
        expect(activity.ran_at).to be >= timestamp
      end
    end

    it "respects limit parameter" do
      activities = service.fetch_since(timestamp: 1.day.ago, limit: 5)
      expect(activities.size).to be <= 5
    end

    it "returns newest activities first" do
      activities = service.fetch_since(timestamp: 1.day.ago)
      timestamps = activities.map(&:ran_at)

      expect(timestamps).to eq(timestamps.sort.reverse)
    end
  end

  describe "#count" do
    it "returns total count of activities" do
      count = service.count
      expect(count).to be > 0
      expect(count).to be_a(Integer)
    end

    it "counts activities with status filter" do
      success_count = service.count(status: :success)
      failed_count = service.count(status: :failed)
      total_count = service.count

      expect(success_count).to be > 0
      expect(failed_count).to be >= 0
      expect(success_count).to be <= total_count
    end

    it "counts activities with search filter" do
      search_count = service.count(search: "photo")
      total_count = service.count

      expect(search_count).to be >= 0
      expect(search_count).to be <= total_count
    end

    it "counts activities with time range" do
      range_count = service.count(since: 5.days.ago, before: 1.day.ago)
      total_count = service.count

      expect(range_count).to be >= 0
      expect(range_count).to be < total_count
    end
  end

  describe "deterministic data generation" do
    it "generates the same activities for the same applet and time range" do
      activities1 = service.fetch(since: 5.days.ago, per_page: 20)
      activities2 = service.fetch(since: 5.days.ago, per_page: 20)

      expect(activities1.map(&:id)).to eq(activities2.map(&:id))
      expect(activities1.map(&:status)).to eq(activities2.map(&:status))
    end

    it "generates different activities for different applets" do
      another_applet = create(:applet,
        trigger_service: trigger_service,
        action_service: action_service)
      another_service = described_class.new(applet_id: another_applet.id)

      activities1 = service.fetch(per_page: 10)
      activities2 = another_service.fetch(per_page: 10)

      # Different applets should generate different activity IDs
      expect(activities1.map(&:id)).not_to eq(activities2.map(&:id))
    end
  end

  describe "realistic mock data" do
    it "generates service-appropriate trigger data" do
      activities = service.fetch(per_page: 10)

      activities.each do |activity|
        expect(activity.trigger_data[:service]).to eq("Instagram")
        expect(activity.trigger_data[:event]).to be_present
        expect(activity.trigger_data[:details]).to be_a(Hash)
      end
    end

    it "generates service-appropriate action data" do
      activities = service.fetch(per_page: 10)

      activities.each do |activity|
        expect(activity.action_data[:service]).to eq("Dropbox")
        expect(activity.action_data[:result]).to be_present
        expect(activity.action_data).to have_key(:completed)
      end
    end

    it "includes realistic error messages for failed activities" do
      # Generate enough activities to likely get some failures
      activities = service.fetch(per_page: 50)
      failed_activities = activities.select { |a| a.status == :failed }

      failed_activities.each do |activity|
        expect(activity.error_message).to be_present
        expect(activity.error_message).to be_a(String)
        expect(activity.error_message.length).to be > 10
      end
    end
  end

  describe "Activity struct methods" do
    it "returns activities that support to_h conversion" do
      activities = service.fetch(per_page: 1)
      activity = activities.first

      hash = activity.to_h
      expect(hash).to be_a(Hash)
      expect(hash[:id]).to eq(activity.id)
      expect(hash[:status]).to eq(activity.status.to_s)
      expect(hash[:ran_at]).to be_a(String) # ISO8601 format
    end

    it "returns activities with helper methods" do
      activities = service.fetch(per_page: 50)

      success_activity = activities.find { |a| a.status == :success }
      if success_activity
        expect(success_activity.success?).to be true
        expect(success_activity.failed?).to be false
        expect(success_activity.skipped?).to be false
      end

      failed_activity = activities.find { |a| a.status == :failed }
      if failed_activity
        expect(failed_activity.success?).to be false
        expect(failed_activity.failed?).to be true
        expect(failed_activity.skipped?).to be false
      end
    end
  end
end
