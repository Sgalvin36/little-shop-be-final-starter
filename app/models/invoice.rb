class Invoice < ApplicationRecord
    belongs_to :customer
    belongs_to :merchant
    belongs_to :coupon, optional: true
    has_many :invoice_items, dependent: :destroy
    has_many :transactions, dependent: :destroy

    validates :status, inclusion: { in: ["shipped", "packaged", "returned"] }

    def total_update
        items = InvoiceItem.where("invoice_id = #{self.id}")
        items.each do |item|
            self.total_price += item["quantity"] * item["unit_price"]
        end

        if self.coupon_id
            coupon = Coupon.find(self.coupon_id)
            if coupon.active && coupon.percentage
                self.total_price -= (self.total_price * coupon.amount_off / 100)
            elsif coupon.active && !coupon.percentage
                result = self.total_price - coupon.amount_off
                self.total_price = [result, 0].max
            end
        end
        return self
    end
end