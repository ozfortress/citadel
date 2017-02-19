module API
  module V1
    class UserSerializer < ActiveModel::Serializer
      type :user

      attributes :id, :name, :description
      attributes :created_at
      attribute(:profile_url) { object.avatar.icon.url }
      attribute :steam_id, key: :steam_id_64
      attribute :steam_id_nice, key: :steam_id_2

      has_many :rosters, serializer: Leagues::RosterSerializer
    end
  end
end
