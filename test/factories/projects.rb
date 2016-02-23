FactoryGirl.define do
  factory :project do
    name        { Faker::Lorem.word + rand(999_999).to_s }
    vanity_url  { Faker::Lorem.word + rand(999_999).to_s }
    description { Faker::Lorem.sentence }
    uuid { Faker::Code.isbn }
    before(:create) { |instance| instance.editor_account = create(:admin) }
    user_count 1
    association :logo
    association :organization
    after(:create) { |instance| instance.update_attributes(best_analysis: create(:analysis, project: instance)) }
  end
end
