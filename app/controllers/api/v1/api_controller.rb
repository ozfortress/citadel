module API
  module V1
    class APIController < ActionController::Base
      rescue_from Exception do |e|
        error(e)
      end

      protected

      def error(err)
        return unless err

        if err.is_a? ActiveRecord::RecordNotFound
          render_not_found
        elsif err.is_a? ActionController::RoutingError
          render_not_found message: 'Unknown route'
        else
          json = { message: 'Internal error' }
          json[:traceback] = err.backtrace if Rails.env.development?

          render_error :internal_server_error, json
        end
      end

      def render_error(status_code, json)
        json[:status] ||= Rack::Utils.status_code(status_code)

        render status: status_code, json: json
      end

      def render_not_found(options = {})
        options[:message] ||= 'Record not found'

        render_error :not_found, options
      end
    end
  end
end
