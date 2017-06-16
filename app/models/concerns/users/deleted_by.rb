module Users
  module DeletedBy
    extend ActiveSupport::Concern

    included do
      belongs_to :deleted_by, optional: true, class_name: 'User'

      scope :existing, -> { where(deleted_by: nil) }
      scope :deleted, -> { where.not(deleted_by: nil) }
      scope :deleted_by, ->(user) { where(deleted_by: user) }
    end

    def deleted?
      !exists?
    end

    def exists?
      deleted_by.nil?
    end

    def delete(user)
      _delete(user)
      save
    end

    def delete!(user)
      _delete(user)
      save!
    end

    def undelete
      _undelete
      save
    end

    def undelete!
      _undelete
      save!
    end

    private

    def _delete(user)
      self.deleted_by = user
      self.deleted_at = Time.zone.now
    end

    def _undelete
      self.deleted_by = nil
    end
  end
end
