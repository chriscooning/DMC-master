FactoryGirl.define do
  sequence(:strong_password) {|n| "My-Ha^-Ha-##{ n }"}
  factory :admin_user do
    email { generate(:email) }
    password { generate(:strong_password) }
    password_confirmation { |u| u.password }
  end
end
