class Applet < ApplicationRecord
  belongs_to :trigger_service, class_name: "Service"
  belongs_to :action_service, class_name: "Service"

  validates :name, presence: true

  scope :enabled, -> { where(enabled: true) }
end
