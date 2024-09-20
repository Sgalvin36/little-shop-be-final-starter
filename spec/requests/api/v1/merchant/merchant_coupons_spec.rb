require "rails_helper"

RSpec.describe "MerchantCoupons Controller" do
    before(:all) do
        @merchants = create_list(:merchant, 6)
        @merchant1_coupons = create_list(:coupon, 3, merchant_id: @merchants[0].id)
        @merchant2_coupons = create_list(:coupon, 2, merchant_id: @merchants[2].id)
        @merchant3_coupons = create_list(:coupon, 4, merchant_id: @merchants[4].id)
    end

    describe "GET /index" do
        it "successfully runs route" do
            get api_v1_merchant_coupons_path(@merchants[0].id)
            expect(response).to be_successful

            coupons = JSON.parse(response.body, symbolize_names: true)
            ids = @merchant1_coupons.map {|each| each.id}
            
            expect(coupons[:data].count).to eq(@merchant1_coupons.count)
            coupons[:data].each do |coupon|
                expect(ids).to include(coupon[:id].to_i)
            end
        end
    end

    describe "GET /show" do
        it "successfully runs route" do
            get api_v1_merchant_coupon_path(@merchants[0].id, @merchant1_coupons[1].id)
            expect(response).to be_successful
            coupon_data = JSON.parse(response.body, symbolize_names: true)
            coupon = coupon_data[:data]
            expect(coupon[:id].to_i).to eq(@merchant1_coupons[1].id)
            expect(coupon[:attributes][:name]).to eq(@merchant1_coupons[1].name)
            expect(coupon[:attributes][:code]).to eq(@merchant1_coupons[1].code)
            expect(coupon[:attributes][:active]).to be_in([true, false])
            if coupon[:attributes][:percentage]
                expect(coupon[:attributes][:percentage_off]).to eq("#{@merchant1_coupons[1].amount_off}%")
            else
                expect(coupon[:attributes][:amount]).to eq("$#{@merchant1_coupons[1].amount_off}")
            end
        end
    end

    describe "POST /create" do
        it "successfully runs route for dollar off" do
            coupon_params = {name: "BOGO256",
            code: "BOGO20202",
            amount_off: 42.00,
            percentage: false,
            merchant_id: @merchants[0].id,
            active: false
            }

            headers = { "CONTENT_TYPE" => "application/json" }
            post api_v1_merchant_coupons_path(@merchants[0].id), headers: headers, params: JSON.generate(coupon: coupon_params)
            
            expect(response).to be_successful

            coupon_data = JSON.parse(response.body, symbolize_names: true)
            coupon = coupon_data[:data]
            
            expect(coupon[:attributes][:merchant_id]).to eq(coupon_params[:merchant_id])
            expect(coupon[:attributes][:name]).to eq(coupon_params[:name])
            expect(coupon[:attributes][:code]).to eq(coupon_params[:code])
            expect(coupon[:attributes][:percentage]).to eq(coupon_params[:percentage])
            expect(coupon[:attributes][:amount]).to eq("$#{'%.2f' % coupon_params[:amount_off]}")
        end

        it "successfully runs route for percentage off" do
            coupon_params = {name: "BOGO256",
            amount_off: 42.00,
            code: "BOGO20204",
            percentage: true,
            merchant_id: @merchants[0].id,
            active: false
            }

            headers = { "CONTENT_TYPE" => "application/json" }
            post api_v1_merchant_coupons_path(@merchants[0].id), headers: headers, params: JSON.generate(coupon: coupon_params)
            
            expect(response).to be_successful

            coupon_data = JSON.parse(response.body, symbolize_names: true)
            coupon = coupon_data[:data]
            
            expect(coupon[:attributes][:merchant_id].to_i).to eq(coupon_params[:merchant_id])
            expect(coupon[:attributes][:name]).to eq(coupon_params[:name])
            expect(coupon[:attributes][:code]).to eq(coupon_params[:code])
            expect(coupon[:attributes][:percentage]).to eq(coupon_params[:percentage])
            expect(coupon[:attributes][:percentage_off]).to eq("#{'%.2f' % coupon_params[:amount_off]}%")
        end
    end

    describe "PATCH /update" do
        it "successfully runs route to activate coupon" do
            coupon_params = {active: true
            }

            headers = { "CONTENT_TYPE" => "application/json" }
            patch api_v1_merchant_coupon_path(@merchants[0].id, @merchant1_coupons[1].id), headers: headers, params: JSON.generate(coupon: coupon_params)
            
            expect(response).to be_successful
            coupon = JSON.parse(response.body, symbolize_names: true)
            expect(coupon[:data][:attributes][:active]).to be true
        end

        it "successfully runs route to deactivate coupon" do
            coupon_params = {active: false
            }

            headers = { "CONTENT_TYPE" => "application/json" }
            patch api_v1_merchant_coupon_path(@merchants[0].id, @merchant1_coupons[1].id), headers: headers, params: JSON.generate(coupon: coupon_params)
            
            expect(response).to be_successful
            coupon = JSON.parse(response.body, symbolize_names: true)
            expect(coupon[:data][:attributes][:active]).to be false
        end
    end

    after (:all) do
        Merchant.destroy_all
    end
end
