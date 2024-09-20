class MerchantCouponSerializer
    include JSONAPI::Serializer
    attributes :name, :code, :merchant_id, :percentage, :active

    attribute :amount, if: Proc.new {|record| !record.percentage} do |object| "$#{'%.2f' % object.amount_off}"
    end
    
    attribute :percentage_off, if: Proc.new {|record| record.percentage} do |object| "#{'%.2f' % object.amount_off}%"
    end
end