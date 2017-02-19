module API
  module V1
    class UserSerializer < ActiveModel::Serializer
      type :user

      attributes :id, :name, :description, :created_at
      attributes :steam_32, :steam_64, :steam_id3
      attribute(:profile_url) { object.avatar.icon.url }

      has_many :rosters, serializer: V1::Leagues::RosterSerializer
    end
  end
end
