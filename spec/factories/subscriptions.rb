FactoryBot.define do
  factory :subscription do
    user
    product
    end_date { Date.today }
  end
end
