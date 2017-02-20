module API
  module V1
    class APIController < ActionController::Base
      before_action :authenticate

      rescue_from Exception do |error|
        handle_error(error) if error
      end

      protected

      def authenticate
        key = request.headers['X-Api-Key']
        @api_key = APIKey.find_by(key: key)

        render_error :unauthorized, message: 'Unauthorized API key' unless @api_key
      end

      def handle_error(error)
        if error.is_a? ActiveRecord::RecordNotFound
          render_not_found
        elsif error.is_a? ActionController::RoutingError
          render_not_found message: 'Unknown route'
        else
          throw error if Rails.env.test?

          json = { message: 'Internal error' }
          json[:traceback] = error.backtrace if Rails.env.development?

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
