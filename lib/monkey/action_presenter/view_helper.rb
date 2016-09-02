require 'action_presenter'

ActionPresenter::ViewHelper.class_eval do
  # The ActionPresenter #present_collection doesn't return a collection
  # Making certain transformations tedious
  def present_collection(collection, &block)
    collection.to_a.compact.map do |object|
      present(object, &block)
    end
  end
end
