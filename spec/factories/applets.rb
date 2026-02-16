FactoryBot.define do
  factory :applet do
    sequence(:name) { |n| "Applet #{n}" }
    description { "A test applet" }
    association :trigger_service, factory: :service
    association :action_service, factory: :service
    enabled { true }
  end
end
