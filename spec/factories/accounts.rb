FactoryGirl.define do
  factory :account do
    subdomain { generate(:login) }

    after(:build) do |account| 
      account.send(:set_s3_hash)
      account.send(:downcase_subdomain)
    end
  end

  factory :account_with_roles, parent: :account do
    after(:build) do |account|
      account.roles = Array.new(2) {|i| create(:role) }
    end
  end

  factory :account_with_permissions, parent: :account do
    after(:create) do |account|
      account.send(:create_permissions)
    end
  end
end
