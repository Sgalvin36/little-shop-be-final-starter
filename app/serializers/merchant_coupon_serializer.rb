class MerchantCouponSerializer
    include JSONAPI::Serializer
    attributes :name, :merchant_id, :amount_off, :percentage
        # :amount if:Proc.new {|record| !record.percentage} do |object| "$#{object.amount_off}", 
        # :percentage_of if: Proc.new {|record| record.percentage} do |object| "#{object.amount_off}%"
end