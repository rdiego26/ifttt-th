# frozen_string_literal: true

require "rails_helper"

RSpec.describe Service, type: :model do
  describe "associations" do
    it "has many trigger applets" do
      service = create(:service)
      applet = create(:applet, trigger_service: service)
      expect(service.trigger_applets).to include(applet)
    end

    it "has many action applets" do
      service = create(:service)
      applet = create(:applet, action_service: service)
      expect(service.action_applets).to include(applet)
    end
  end

  describe "validations" do
    it "requires a name" do
      service = build(:service, name: nil)
      expect(service).not_to be_valid
      expect(service.errors[:name]).to include("can't be blank")
    end

    it "requires a slug" do
      service = build(:service, slug: nil)
      expect(service).not_to be_valid
      expect(service.errors[:slug]).to include("can't be blank")
    end

    it "requires a unique slug" do
      first_service = create(:service)
      service = build(:service, slug: first_service.slug)
      expect(service).not_to be_valid
      expect(service.errors[:slug]).to include("has already been taken")
    end
  end
end
