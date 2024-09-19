FactoryBot.define do
  factory :coupon do
    name { Faker::Commerce.promotion_code(digits: 2) }
    active { Faker::Boolean.boolean(true_ratio: 0.6) }
    percentage { Faker::Boolean.boolean(true_ratio: 0.5) }
    amount_off { Faker::Number.decimal(l_digits: 2, r_digits: 2) }
  end
end
