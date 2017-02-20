class APIKey < ApplicationRecord
  belongs_to :user, optional: true

  validates :name, allow_blank: true, length: { maximum: 64 }
  validates :user, allow_nil: true, uniqueness: true
  validates :key, presence: true

  before_validation :generate_unique_key, on: :create

  def generate_unique_key
    loop do
      self.key = SecureRandom.hex(32)

      break unless APIKey.exists?(key: key)
    end
  end
end
