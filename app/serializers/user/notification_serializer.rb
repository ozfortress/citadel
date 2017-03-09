class User
  class NotificationSerializer < ActiveModel::Serializer
    attributes :id, :read, :message, :link
  end
end
