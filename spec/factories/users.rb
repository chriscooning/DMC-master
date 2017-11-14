FactoryGirl.define do
  factory :user_without_account, class: User do
    full_name "Chuck Norris"
    email { generate(:email) }
    password "foobar"
    password_confirmation { |u| u.password }
    confirmed_at 1.hour.ago
  end

  factory :user, parent: :user_without_account do
    full_name "Bruce Lee"
  end

  factory :confirmed_user, parent: :user do |u|
    confirmed_at 1.hour.ago
  end

  factory :user_with_token, parent: :confirmed_user do |u|
    authentication_token 'some_secret_authentication_token'
    authentication_token_expires_at 1.year.from_now
  end

  factory :not_confirmed_user, parent: :user do |u|
    confirmed_at nil
  end
end
