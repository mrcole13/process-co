class Payment < ApplicationRecord
    belongs_to :resident
    belongs_to :property
end
