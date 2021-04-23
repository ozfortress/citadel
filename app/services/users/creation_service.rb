module Users
  module CreationService
    include BaseService

    def call(params, flash = {})
      user = User.new(params)

      user.transaction do
        EmailConfirmationService.send_email(user, flash) if user.valid? && user.email_changed? && user.email?

        user.save || rollback!

        # Log name history
        user.names.create!(name: user.name, approved_by: user)
      end

      user
    end
  end
end
