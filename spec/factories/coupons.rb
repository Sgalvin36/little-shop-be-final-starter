FactoryBot.define do
  factory :coupon do
    name { "MyString" }
    active { false }
    percentage { false }
    amount_off { 1.5 }
  end
end
