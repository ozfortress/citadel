module API
  module V1
    class TeamSerializer < ActiveModel::Serializer
      type :team

      attributes :id, :name, :description
      attribute(:avatar_url) { object.avatar.url }
      attribute(:avatar_thumb_url) { object.avatar.thumb.url }
      attribute(:avatar_icon_url) { object.avatar.icon.url }

      has_many :users, key: :players, serializer: UserSerializer
      has_many :rosters, serializer: Leagues::RosterSerializer
    end
  end
end
