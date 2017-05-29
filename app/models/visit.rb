class Visit < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :api_key, optional: true

  has_many :events, class_name: 'Ahoy::Event'
end
