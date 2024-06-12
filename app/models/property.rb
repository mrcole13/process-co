class Property < ApplicationRecord
    has_many :residents
    has_many :properties, class_name: "Property", foreign_key: :property_manager_id
    belongs_to :property_manager, class_name: "Property", optional: true
end
