class Api::V1::Merchants::CouponsController < ApplicationController
    def index
        merchant= Merchant.find(params[:merchant_id])
        coupons = merchant.coupons

        render json: MerchantCouponSerializer.new(coupons)
    end
end
