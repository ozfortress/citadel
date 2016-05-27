FactoryGirl.define do
  factory :notification do
    user
    read false
    message "Your name was changed to 'coach'"
    link { "/users/#{user.id}" }
  end
end
