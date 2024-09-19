class Api::V1::Merchants::CouponsController < ApplicationController
    def index
        merchant= Merchant.find(params[:merchant_id])
        coupons = merchant.coupons

        render json: MerchantCouponSerializer.new(coupons)
    end

    def show
        merchant= Merchant.find(params[:merchant_id])
        coupon = merchant.coupons.find(params[:id])

        render json: MerchantCouponSerializer.new(coupon)
    end
end
