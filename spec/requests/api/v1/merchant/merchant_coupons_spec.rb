require "rails_helper"

RSpec.describe "MerchantCoupons Controller" do
    before(:all) do
        @merchants = create_list(:merchant, 6)
        @merchant1_coupons = create_list(:coupon, 3, merchant_id: @merchants[0].id)
        @merchant2_coupons = create_list(:coupon, 2, merchant_id: @merchants[2].id)
        @merchant3_coupons = create_list(:coupon, 4, merchant_id: @merchants[4].id)
    end
    describe "GET /index" do
        it "successfully runs route" do
            get api_v1_merchant_coupons_path(@merchants[0].id)
            # binding.pry
            expect(response).to be_successful
        end
    end

    describe "GET /show" do

    end

    describe "POST /create" do

    end

    describe "PATCH /update" do

    end

    after (:all) do
        Merchant.destroy_all
    end
end
