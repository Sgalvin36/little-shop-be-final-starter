class Coupon < ApplicationRecord
    belongs_to :merchant
    has_many :invoices

    def self.check_active(params)
        merchant = Merchant.find(params[:merchant_id])
        merchant.coupons.where("active = true").count
    end

end
