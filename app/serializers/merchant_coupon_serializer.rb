class MerchantCouponSerializer
    include JSONAPI::Serializer
    set_type :coupon
    attributes :name, :code, :merchant_id, :percentage

    attribute :active do |coupon|
        coupon.active ? "Active" : "Inactive"
    end
    
    attribute :amount, if: Proc.new {|record| !record.percentage} do |object| "$#{'%.2f' % object.amount_off}"
    end
    
    attribute :percentage_off, if: Proc.new {|record| record.percentage} do |object| "#{'%.2f' % object.amount_off}%"
    end
end