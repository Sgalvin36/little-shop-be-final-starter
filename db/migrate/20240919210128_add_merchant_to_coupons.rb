class AddMerchantToCoupons < ActiveRecord::Migration[7.1]
  def change
    add_reference :invoices, :coupon
  end
end
