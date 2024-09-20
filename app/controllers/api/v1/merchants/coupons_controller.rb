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

    def create
        new_coupon = Coupon.create(coupon_params)
        
        render json: MerchantCouponSerializer.new(new_coupon), status: 201
    end

    def update
        merchant= Merchant.find(params[:merchant_id])
        coupon = merchant.coupons.find(params[:id])
        updated_coupon = coupon.update(coupon_update_params)

        render json: MerchantCouponSerializer.new(coupon)
    end
    
    private

    def coupon_params
        params.require(:coupon).permit(:name, :code, :amount_off, :percentage, :active, :merchant_id)
    end

    def coupon_update_params
        params.require(:coupon).permit(:active)
    end
end
