FactoryGirl.define do
  factory :user_notification, class: User::Notification do
    user
    read false
    message "Your name was changed to 'coach'"
    link { "/users/#{user.id}" }
  end
end
