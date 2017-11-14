FactoryGirl.define do
  sequence(:announcement_title) {|n| "announcement title #{ n }" }
  sequence(:announcement_text)  {|n| "announcement text #{ n }" }

  factory :announcement do
    title { generate(:announcement_title) }
    text  { generate(:announcement_text) }
  end
end
