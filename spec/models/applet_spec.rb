# frozen_string_literal: true

require "rails_helper"

RSpec.describe Applet, type: :model do
  describe "associations" do
    it "belongs to a trigger service" do
      applet = create(:applet)
      expect(applet.trigger_service).to be_a(Service)
    end

    it "belongs to an action service" do
      applet = create(:applet)
      expect(applet.action_service).to be_a(Service)
    end
  end

  describe "validations" do
    it "requires a name" do
      applet = build(:applet, name: nil)
      expect(applet).not_to be_valid
      expect(applet.errors[:name]).to include("can't be blank")
    end
  end

  describe "scopes" do
    describe ".enabled" do
      let!(:enabled_applet) { create(:applet, enabled: true) }
      let!(:disabled_applet) { create(:applet, enabled: false) }

      it "returns only enabled applets" do
        expect(Applet.enabled).to include(enabled_applet)
        expect(Applet.enabled).not_to include(disabled_applet)
      end
    end
  end
end
