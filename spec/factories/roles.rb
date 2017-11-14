FactoryGirl.define do
  factory :role do
    name { generate(:login) }
  end
end
