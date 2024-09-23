class Coupon < ApplicationRecord
    belongs_to :merchant
    has_many :invoices

    validates :name, :code, :amount_off, :merchant_id, presence: {strict: true}
    validates :amount_off, numericality: {greater_than: 0}

    def self.check_active(params)
        merchant = Merchant.find(params[:merchant_id])
        merchant.coupons.where("active = true").count
    end

    def self.sorted_by_active(merchant)
        merchant.coupons.order(active: :desc)
    end

end
