module Paths
  extend ActiveSupport::Concern

  def paths
    Paths.new(self)
  end

  included do
    class Paths
      include Rails.application.routes.url_helpers

      attr_reader :instance

      def initialize(instance)
        @instance = instance
      end

      def dom_id(prefix = nil)
        ActionView::RecordIdentifier.dom_id(instance, prefix)
      end

      private

      def respond_to_missing?(method, _include_private = false)
        instance.respond_to?(method)
      end

      def method_missing(method, *args, &block)
        if instance.respond_to?(method)
          instance.send(method, *args, &block)
        else
          super
        end
      end
    end
  end

  class_methods do
    def paths(&block)
      Paths.class_eval(&block)
    end
  end
end
