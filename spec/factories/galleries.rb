FactoryGirl.define do
  factory :gallery do
    name "Gallery"
    visible true

    after(:create) do |resource|
      resource.send(:create_permissions)
    end
  end

  factory :deleted_gallery, parent: :gallery do
    deleted_at DateTime.now
  end
end
