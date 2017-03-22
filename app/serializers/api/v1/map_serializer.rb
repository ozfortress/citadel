module API
  module V1
    class MapSerializer < ActiveModel::Serializer
      type :map

      attributes :id, :name, :description
    end
  end
end
