FactoryGirl.define do
  sequence(:invitation_email){|n| "invitation.email+#{ n }@example.com" }

  factory :invitation_request do
    association :gallery
    email { generate(:invitation_email) }
  end

  factory :invitation_request_with_hash, parent: :invitation_request do
    before(:create) do |resource|
      resource.invitation_hash = SecureRandom.hex
    end
  end
end
