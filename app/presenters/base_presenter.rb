class BasePresenter
  include ERB::Util

  attr_reader :object, :view_context

  def self.presenter(object)
    "#{object.class}Presenter".constantize
  end

  def self.presents(name)
    define_method(name) { object }
  end

  def initialize(object, view_context)
    @object = object
    @view_context = view_context
  end

  private

  def respond_to_missing?(method, _include_private = false)
    view_context.respond_to?(method)
  end

  def method_missing(method, *args, &block)
    if view_context.respond_to?(method)
      view_context.send(method, *args, &block)
    else
      super
    end
  end
end
