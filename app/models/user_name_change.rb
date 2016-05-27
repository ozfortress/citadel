class UserNameChange < ActiveRecord::Base
  include Rails.application.routes.url_helpers

  belongs_to :user, autosave: true
  belongs_to :approved_by, class_name: 'User'
  belongs_to :denied_by, class_name: 'User'

  validates :user, presence: true
  validates :name, presence: true, length: { in: 1..64 }

  validate :unique_name, on: :create
  validate :only_one_request_per_user, on: :create

  after_update do
    if approved_by
      user.notify!("The request to change your name to '#{name}' was accepted!", user_path(user))
    elsif denied_by
      user.notify!("The request to change your name to '#{name}' was denied.", user_path(user))
    end
  end

  def pending?
    !approved_by && !denied_by
  end

  def self.pending
    all.where(approved_by: nil, denied_by: nil)
  end

  def approve!(user, approved)
    if approved
      self.approved_by = user
      self.user.update!(name: name)
    else
      self.denied_by = user
    end
    save!
  end

  private

  def unique_name
    if user.present? && name.present? && pending? && user.name == name
      errors.add(:name, 'must be different to the current name')
    end
  end

  def only_one_request_per_user
    if user.present? && pending? && !user.pending_names.empty?
      errors.add(:name, 'a name request is already pending')
    end
  end
end
