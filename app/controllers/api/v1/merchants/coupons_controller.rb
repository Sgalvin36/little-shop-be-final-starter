class Api::V1::Merchants::CouponsController < ApplicationController
    def index
        coupons = Coupon.all

        render json: MerchantCouponSerializer.new(coupons)
    end

    def show
        coupon =Coupon.find(params[:id])

        render json: MerchantCouponSerializer.new(coupon)
    end

    def create
        new_coupon = Coupon.create(coupon_params)
        
        render json: MerchantCouponSerializer.new(new_coupon), status: 201
    end
    
    private

    def coupon_params
        params.require(:coupon).permit(:name, :amount_off, :percentage, :active, :merchant_id)
    end
end
