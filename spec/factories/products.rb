FactoryBot.define do
  factory :product do
    name { Faker::Movie.title }
    price { Faker::Number.number(digits: 9) }
  end
end
