module API
  module V1
    class APIController < ActionController::Base
      rescue_from Exception do |e|
        error(e)
      end

      def routing_error
        raise ActionController::RoutingError.new(params[:path])
      end

      protected

      def error(err)
        return unless err

        if err.is_a? ActiveRecord::RecordNotFound
          render_404
        else
          json = { status: 500, message: 'Internal error' }
          json[:traceback] = err.backtrace if Rails.env.development?

          render_error json
        end
      end

      def render_error(json)
        render status: json[:status], json: json
      end

      def render_404(options = {})
        options[:message] ||= 'Record not found'
        render_error options.merge(status: 404)
      end
    end
  end
end
