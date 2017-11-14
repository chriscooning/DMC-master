FactoryGirl.define do
  factory :folder do
    name "Typical Folder"
    hide_folder false
    association :gallery

    after(:create) do |resource|
      resource.send(:create_permissions)
    end
  end

  factory :passworded_folder, parent: :folder do
    enable_password true
    password 'password'
  end

  factory :deleted_folder, parent: :folder do
    deleted_at DateTime.now
  end

  factory :hidden_folder, parent: :folder do
    hide_folder true
  end
end
