module Users
  module CreationService
    include BaseService

    def call(params, flash = {})
      user = User.new(params)

      user.transaction do
        if user.valid?
          EmailConfirmationService.send_email(user, flash) if user.email_changed? && user.email?
        end

        user.save || rollback!

        # Log name history
        user.names.create!(name: user.name, approved_by: user)
      end

      user
    end
  end
end
