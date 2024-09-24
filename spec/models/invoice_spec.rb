require "rails_helper"

RSpec.describe Invoice do
    it { should belong_to :merchant }
    it { should belong_to :customer }
    it { should belong_to(:coupon).optional}
    it { should validate_inclusion_of(:status).in_array(%w(shipped packaged returned)) }

    it "does not go below zero owed when coupon is applied" do
        merchant = Merchant.create(name: "Steve")
        coupon = Coupon.create(name:"20OFF", code: "20DOLLHAIRS", merchant_id: merchant.id, percentage: false, active: true, amount_off: 20.00)
        item = Item.create(name: "Hairties", description: "Some funny things", unit_price: 2.00, merchant_id:merchant.id)
        customer = Customer.create(first_name: "Frita", last_name: "Lays")
        invoice = Invoice.create(merchant_id: merchant.id, customer_id: customer.id, status: "processing", coupon_id: coupon.id)
        invoice_item = InvoiceItem.create(item_id: item.id, invoice_id: invoice.id, quantity: 3, unit_price: item.unit_price)

        expect(invoice[:total_price]).to eq(0.00)
    end
end