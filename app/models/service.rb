class Service < ApplicationRecord
  has_many :trigger_applets, class_name: "Applet", foreign_key: :trigger_service_id
  has_many :action_applets, class_name: "Applet", foreign_key: :action_service_id

  validates :name, presence: true
  validates :slug, presence: true, uniqueness: true
end
