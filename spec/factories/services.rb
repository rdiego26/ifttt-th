FactoryBot.define do
  factory :service do
    sequence(:name) { |n| "Service #{n}" }
    sequence(:slug) { |n| "service_#{n}" }
    icon_url { "https://example.com/icon.png" }
    brand_color { "#000000" }
  end
end
