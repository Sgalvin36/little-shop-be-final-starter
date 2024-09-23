class Api::V1::Merchants::CouponsController < ApplicationController
    rescue_from PG::UniqueViolation, with: :not_unique_response
    rescue_from ActionController::ParameterMissing, with: :bad_request_response


    before_action :set_merchant, only: [:index, :show, :update]
    
    def index
        if params[:sorted].present? && params[:sorted] == "active"
            # binding.pry
            coupons = Coupon.sorted_by_active(@merchant)
        else
            coupons = @merchant.coupons
        end
    
        render json: MerchantCouponSerializer.new(coupons)
    end

    def show
        coupon = @merchant.coupons.find(params[:id])
        render json: MerchantCouponSerializer.new(coupon)
    end

    def create
        if Coupon.check_active(coupon_params) < 5
            new_coupon = Coupon.create(coupon_params)
            render json: MerchantCouponSerializer.new(new_coupon), status: 201
        else
            render json: ErrorSerializer.over_active, status: :bad_request
        end
    end

    def update
        coupon = @merchant.coupons.find(params[:id])
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

    def not_found_response(exception)
        render json: ErrorSerializer.format_errors(exception), status: :not_found
    end

    def bad_request_response(exception)
        render json: ErrorSerializer.format_errors(exception), status: :bad_request
    end

    def not_unique_response(exception)
        render json: ErrorSerializer.format_unique(exception), status: :conflict
    end

    def set_merchant
        if params.has_key?(:merchant_id) && params[:merchant_id] != ""
            @merchant= Merchant.find(params[:merchant_id])
        else
            raise ActionController::ParameterMissing, "Parameters are missing"
        end
    end
end
