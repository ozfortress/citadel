class League
  class Roster
    class TransferRequestPresenter < BasePresenter
      presents :transfer_request

      # rubocop:disable Rails/OutputSafety
      PENDING_MESSAGE = '%{created_by} requested %{user} be transferred %{direction} '\
                        '%{roster}%{leaving_message}'.html_safe

      APPROVED_MESSAGE = '%{approved_by} approved %{user}\'s transfer %{direction} '\
                         '%{roster}%{leaving_message} (requested by %{created_by})'.html_safe

      DENIED_MESSAGE = '%{denied_by} denied %{user}\'s transfer %{direction} '\
                       '%{roster}%{leaving_message} (requested by %{created_by})'.html_safe

      LEAVING_MESSAGE = ', out of %{leaving_roster} in %{division}'.html_safe
      # rubocop:enable Rails/OutputSafety

      def user
        @user ||= present(transfer_request.user)
      end

      def created_by
        @created_by ||= present(transfer_request.created_by)
      end

      def roster
        @roster ||= present(transfer_request.roster)
      end

      def leaving_roster
        @leaving_roster ||= present(transfer_request.leaving_roster)
      end

      def approved_by
        @approved_by ||= present(transfer_request.approved_by)
      end

      def denied_by
        @denied_by ||= present(transfer_request.denied_by)
      end

      def listing
        safe_join([transfer_request.created_at.strftime('%c'), message], ' ')
      end

      def message
        message_template % message_params
      end

      def leaving_message
        if transfer_request.leaving_roster
          LEAVING_MESSAGE % { leaving_roster: leaving_roster.link, division: leaving_roster.division.name }
        else
          ''
        end
      end

      def direction_message
        if transfer_request.is_joining?
          'into'
        else
          'out of'
        end
      end

      def transfer_message
        if transfer_request.is_joining?
          safe_join(["pending transfer to '", roster.link, "'"])
        else
          safe_join(["pending transfer out of '", roster.link, "'"])
        end
      end

      private

      def message_template
        if transfer_request.pending?
          PENDING_MESSAGE
        elsif transfer_request.approved?
          APPROVED_MESSAGE
        else
          DENIED_MESSAGE
        end
      end

      def user_param
        roster = transfer_request.leaving_roster

        if roster && transfer_request.user.can?(:edit, roster.team)
          user.link + ' ' + content_tag(:span, 'captain', class: 'label label-warning')
        else
          user.link
        end
      end

      def message_params
        if transfer_request.approved?
          { approved_by: approved_by.link }
        elsif transfer_request.denied?
          { denied_by: denied_by.link }
        else
          {}
        end.merge(
          created_by: created_by.link, user: user_param, direction: direction_message,
          roster: roster.link, leaving_message: leaving_message
        )
      end
    end
  end
end
