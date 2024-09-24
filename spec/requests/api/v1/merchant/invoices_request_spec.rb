require "rails_helper"

RSpec.describe "Merchant invoices endpoints" do
    before :each do
        @merchant2 = create(:merchant)
        @merchant1 = create(:merchant)

        @customer1 = create(:customer)
        @customer2 = create(:customer)

        @invoice1 = Invoice.create!(customer: @customer1, merchant: @merchant1, status: "packaged")
        create_list(:invoice, 3, merchant_id: @merchant1.id, customer_id: @customer1.id) # shipped by default
        @invoice2 = Invoice.create!(customer: @customer1, merchant: @merchant2, status: "shipped")
    end

    describe "GET#index" do
        it "should return all invoices for a given merchant based on status param" do
            get "/api/v1/merchants/#{@merchant1.id}/invoices?status=packaged"

            json = JSON.parse(response.body, symbolize_names: true)

            expect(response).to be_successful
            expect(json[:data].count).to eq(1)
            expect(json[:data][0][:id]).to eq(@invoice1.id.to_s)
            expect(json[:data][0][:type]).to eq("invoice")
            expect(json[:data][0][:attributes][:customer_id]).to eq(@customer1.id)
            expect(json[:data][0][:attributes][:merchant_id]).to eq(@merchant1.id)
            expect(json[:data][0][:attributes][:status]).to eq("packaged")
        end

        it "should get multiple invoices if they exist for a given merchant and status param" do
            get "/api/v1/merchants/#{@merchant1.id}/invoices?status=shipped"

            json = JSON.parse(response.body, symbolize_names: true)

            expect(response).to be_successful
            expect(json[:data].count).to eq(3)
        end

        it "should return all invoices if no status parameter is passed" do
            get "/api/v1/merchants/#{@merchant1.id}/invoices"

            json = JSON.parse(response.body, symbolize_names: true)

            expect(response).to be_successful
            expect(json[:data].count).to eq(4)
        end
        it "should only get invoices for merchant given" do
            get "/api/v1/merchants/#{@merchant2.id}/invoices?status=shipped"

            json = JSON.parse(response.body, symbolize_names: true)

            expect(response).to be_successful
            expect(json[:data].count).to eq(1)
            expect(json[:data][0][:id]).to eq(@invoice2.id.to_s)
        end

        it "should return 404 and error message when merchant is not found" do
            get "/api/v1/merchants/100000/customers"

            json = JSON.parse(response.body, symbolize_names: true)

            expect(response).to have_http_status(:not_found)
            expect(json[:message]).to eq("Your query could not be completed")
            expect(json[:errors]).to be_a Array
            expect(json[:errors].first).to eq("Couldn't find Merchant with 'id'=100000")
        end
    end

    describe "GET#show" do
        it "can return a merchant's specific invoice" do
            invoice_test = Invoice.create(customer: @customer2, merchant: @merchant1, status: "packaged")

            get api_v1_merchant_invoice_path(invoice_test[:merchant_id], invoice_test.id)
            expect(response).to be_successful

            data = JSON.parse(response.body, symbolize_names: true)
            expect(data[:data][:id].to_i).to eq(invoice_test[:id])
            expect(data[:data][:type]).to eq("invoice")
            
            expect(data[:data][:attributes][:customer_id]).to eq(invoice_test[:customer_id])
            expect(data[:data][:attributes][:merchant_id]).to eq(invoice_test[:merchant_id])
            expect(data[:data][:attributes][:status]).to eq(invoice_test[:status])
            expect(data[:data][:attributes][:coupon_id]).to eq(invoice_test[:coupon_id])
        end

        it "can return a merchant's specific invoice with the coupon used" do
            coupon = create(:coupon, merchant_id: @merchant1.id)
            invoice_test = Invoice.create(customer: @customer2, merchant: @merchant1, status: "packaged", coupon: coupon)

            get api_v1_merchant_invoice_path(invoice_test[:merchant_id], invoice_test.id)
            expect(response).to be_successful

            data = JSON.parse(response.body, symbolize_names: true)
            expect(data[:data][:attributes][:customer_id]).to eq(invoice_test[:customer_id])
            expect(data[:data][:attributes][:merchant_id]).to eq(invoice_test[:merchant_id])
            expect(data[:data][:attributes][:status]).to eq(invoice_test[:status])
            expect(data[:data][:attributes][:coupon_id]).to eq(invoice_test[:coupon_id])
        end

        it "can return a specific invoice with the total added on" do
            invoice_test = Invoice.create(customer: @customer2, merchant: @merchant1, status: "packaged")

            get api_v1_merchant_invoice_path(invoice_test[:merchant_id], invoice_test.id)
            expect(response).to be_successful

            data = JSON.parse(response.body, symbolize_names: true)
            expect(data[:data][:id].to_i).to eq(invoice_test[:id])
            expect(data[:data][:type]).to eq("invoice")
            
            expect(data[:data][:attributes][:customer_id]).to eq(invoice_test[:customer_id])
            expect(data[:data][:attributes][:merchant_id]).to eq(invoice_test[:merchant_id])
            expect(data[:data][:attributes][:status]).to eq(invoice_test[:status])
            expect(data[:data][:attributes][:coupon_id]).to eq(invoice_test[:coupon_id])
            expect(data[:data][:attributes][:total_price]).to eq("0.0")
        end

        it "addeds items to the total correctly" do
            invoice_test = Invoice.create(customer: @customer2, merchant: @merchant1, status: "packaged")
            item = Item.create!(name: "Hairties", description: "Some funny things", unit_price: 5.00, merchant_id: @merchant1.id)
            invoice_item = InvoiceItem.create!(item_id: item.id, invoice_id: invoice_test.id, quantity: 4, unit_price: item.unit_price)

            get api_v1_merchant_invoice_path(invoice_test[:merchant_id], invoice_test.id)
            expect(response).to be_successful

            data = JSON.parse(response.body, symbolize_names: true)
            expect(data[:data][:id].to_i).to eq(invoice_test[:id])
            expect(data[:data][:type]).to eq("invoice")
            
            expect(data[:data][:attributes][:customer_id]).to eq(invoice_test[:customer_id])
            expect(data[:data][:attributes][:merchant_id]).to eq(invoice_test[:merchant_id])
            expect(data[:data][:attributes][:status]).to eq(invoice_test[:status])
            expect(data[:data][:attributes][:coupon_id]).to eq(invoice_test[:coupon_id])
            expect(data[:data][:attributes][:total_price]).to eq("20.0")
        end

        it "applies the pecentage off coupon correctly" do
            item = Item.create!(name: "Hairties", description: "Some funny things", unit_price: 5.00, merchant_id: @merchant1.id)
            coupon = Coupon.create!(name:"20OFF", code: "20DOLLHAIRS", merchant_id: @merchant1.id, percentage: true, active: true, amount_off: 20.00)
            invoice_test = Invoice.create(customer: @customer2, merchant: @merchant1, status: "packaged", coupon_id: coupon.id)
            invoice_item = InvoiceItem.create!(item_id: item.id, invoice_id: invoice_test.id, quantity: 4, unit_price: item.unit_price)
            get api_v1_merchant_invoice_path(invoice_test[:merchant_id], invoice_test.id)
            expect(response).to be_successful

            data = JSON.parse(response.body, symbolize_names: true)
            expect(data[:data][:id].to_i).to eq(invoice_test[:id])
            expect(data[:data][:type]).to eq("invoice")
            
            expect(data[:data][:attributes][:customer_id]).to eq(invoice_test[:customer_id])
            expect(data[:data][:attributes][:merchant_id]).to eq(invoice_test[:merchant_id])
            expect(data[:data][:attributes][:status]).to eq(invoice_test[:status])
            expect(data[:data][:attributes][:coupon_id]).to eq(invoice_test[:coupon_id])
            expect(data[:data][:attributes][:total_price]).to eq("16.0")
        end

        it "applies the amount off coupon correctly" do
            item = Item.create!(name: "Hairties", description: "Some funny things", unit_price: 5.00, merchant_id: @merchant1.id)
            coupon = Coupon.create!(name:"20OFF", code: "20DOLLHAIRS", merchant_id: @merchant1.id, percentage: false, active: true, amount_off: 10.00)
            invoice_test = Invoice.create(customer: @customer2, merchant: @merchant1, status: "packaged", coupon_id: coupon.id)
            invoice_item = InvoiceItem.create!(item_id: item.id, invoice_id: invoice_test.id, quantity: 4, unit_price: item.unit_price)
            get api_v1_merchant_invoice_path(invoice_test[:merchant_id], invoice_test.id)
            expect(response).to be_successful

            data = JSON.parse(response.body, symbolize_names: true)
            expect(data[:data][:id].to_i).to eq(invoice_test[:id])
            expect(data[:data][:type]).to eq("invoice")
            
            expect(data[:data][:attributes][:customer_id]).to eq(invoice_test[:customer_id])
            expect(data[:data][:attributes][:merchant_id]).to eq(invoice_test[:merchant_id])
            expect(data[:data][:attributes][:status]).to eq(invoice_test[:status])
            expect(data[:data][:attributes][:coupon_id]).to eq(invoice_test[:coupon_id])
            expect(data[:data][:attributes][:total_price]).to eq("10.0")
        end
    end
end