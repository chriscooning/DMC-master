FactoryGirl.define do
  factory :asset do
    sequence :title do |n|
      "Image #{n}"
    end
    sequence :file_file_name do |n|
      "image#{n}.jpg"
    end
    association :folder, account: account
    file_content_type 'image/jpg'
    file_file_size 1024
    description { "description" }
  end

  factory :deleted_asset, parent: :asset do
    deleted_at DateTime.now
  end

  factory :downloadable_asset, parent: :asset do
    downloadable true
  end

  factory :asset_with_secret, parent: :asset do
    secret SecureRandom.hex(8)
  end
end
