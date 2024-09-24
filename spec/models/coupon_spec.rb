require 'rails_helper'

RSpec.describe Coupon, type: :model do
    it { should have_many(:invoices)}
    it "raises ActiveRecord::StrictValidationError for null merchant_id" do
        expect do
            Coupon.create!(merchant_id: nil)
        end.to raise_error(ActiveModel::StrictValidationFailed, /Merchant can't be blank/)
    end
    
    it "raises ActiveRecord::StrictValidationError for null name" do
        expect do
            Coupon.create!(name: nil)
        end.to raise_error(ActiveModel::StrictValidationFailed, /Merchant can't be blank/)
    end

    it "raises ActiveRecord::StrictValidationError for null code" do
        expect do
            Coupon.create!(code: nil)
        end.to raise_error(ActiveModel::StrictValidationFailed, /Merchant can't be blank/)
    end

    it "raises ActiveRecord::StrictValidationError for null amount_off" do
        expect do
            Coupon.create!(amount_off: nil)
        end.to raise_error(ActiveModel::StrictValidationFailed, /Merchant can't be blank/)
    end

    it "can find a given merchant active coupon count" do
        merchant = Merchant.create(name: "Steve")
        params = {merchant_id: merchant.id}
        test_of_method = Coupon.check_active(params)

        expect(test_of_method).to eq(0)

        create_list(:coupon, 3, merchant_id: merchant.id, active: true)

        test_of_method = Coupon.check_active(params)

        expect(test_of_method).to eq(3)
    end

    it "can sort a given merchant active coupon count from inactive" do
        merchant = Merchant.create(name: "Steve")
        create_list(:coupon, 2, merchant_id: merchant.id, active: true)
        create_list(:coupon, 3, merchant_id: merchant.id, active: false)
        create_list(:coupon, 2, merchant_id: merchant.id, active: true)

        test_of_method = Coupon.sorted_by_active(merchant)

        expect(test_of_method.length).to eq(7)
        (0..3).each {|n| expect(test_of_method[n][:active]).to eq true }
        (4..6).each {|n| expect(test_of_method[n][:active]).to eq false}
    end
end
