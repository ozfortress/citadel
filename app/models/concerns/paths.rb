module Paths
  extend ActiveSupport::Concern

  def paths
    @paths ||= self.class.paths_class.new(self)
  end

  class_methods do
    attr_reader :paths_class

    # rubocop:disable Metrics/MethodLength
    def paths(&block)
      @paths_class = Class.new do
        include Rails.application.routes.url_helpers

        attr_reader :instance

        def initialize(instance)
          @instance = instance
        end

        def dom_id(prefix = nil)
          ActionView::RecordIdentifier.dom_id(instance, prefix)
        end

        private :respond_to_missing?, :method_missing

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

      @paths_class.class_eval(&block)
    end
    # rubocop:enable Metrics/MethodLength
  end
end
