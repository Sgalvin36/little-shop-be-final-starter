require "rails_helper"

RSpec.describe "MerchantCoupons Controller" do
    before(:all) do
        @merchants = create_list(:merchant, 6)
        @merchant1_coupons = create_list(:coupon, 3, merchant_id: @merchants[0].id)
        @merchant2_coupons = create_list(:coupon, 2, merchant_id: @merchants[2].id)
        @merchant3_coupons = create_list(:coupon, 4, merchant_id: @merchants[4].id)
    end
    
    describe "GET /index" do
        it "successfully runs route and gets all coupons for one merchant" do
            get api_v1_merchant_coupons_path(@merchants[0].id)
            expect(response).to be_successful

            coupons = JSON.parse(response.body, symbolize_names: true)
            ids = @merchant1_coupons.map {|each| each.id}
            
            expect(coupons[:data].count).to eq(@merchant1_coupons.count)
            coupons[:data].each do |coupon|
                expect(ids).to include(coupon[:id].to_i)
            end
        end

        it "can sort coupons by active and inactive" do
            create_list(:coupon, 3, merchant_id: @merchants[1].id, active: false)
            create_list(:coupon, 3, merchant_id: @merchants[1].id, active: true)
            create_list(:coupon, 3, merchant_id: @merchants[1].id, active: false)
            get "/api/v1/merchants/#{@merchants[1].id}/coupons?sorted=active"
            expect(response).to be_successful
            data = JSON.parse(response.body, symbolize_names: true)
            expect(data[:data].count).to eq(9)

            coupons = data[:data]
            (0..2).each {|n| expect(coupons[n][:attributes][:active]).to eq "Active" }
            (3..8).each {|n| expect(coupons[n][:attributes][:active]).to eq "Inactive"}
        end

        describe "Sad Path" do
            it "handles not being given a valid merchant id gracefully" do
                get api_v1_merchant_coupons_path(0)

                expected = {errors: ["Couldn't find Merchant with 'id'=0"], message: "Your query could not be completed"}

                expect(response).to_not be_successful
                data = JSON.parse(response.body, symbolize_names: true)
                expect(data).to eq(expected)
            end

            it "raises an error if merchant_id is null" do
                expect{ get api_v1_merchant_coupons_path("") }.to raise_error(ActionController::UrlGenerationError)
            end
        end
    end

    describe "GET /show" do
        it "successfully runs route and gets one coupon" do
            get api_v1_merchant_coupon_path(@merchants[0].id, @merchant1_coupons[1].id)
            expect(response).to be_successful
            coupon_data = JSON.parse(response.body, symbolize_names: true)
            coupon = coupon_data[:data]
            expect(coupon[:id].to_i).to eq(@merchant1_coupons[1].id)
            expect(coupon[:attributes][:name]).to eq(@merchant1_coupons[1].name)
            expect(coupon[:attributes][:code]).to eq(@merchant1_coupons[1].code)
            expect(coupon[:attributes][:active]).to be_in(["Active", "Inactive"])
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
        
        describe "Sad Path" do
            it "doesn't allow duplicate codes to go through on creation" do
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

                coupon_params = {name: "BOGO265",
                code: "BOGO20202",
                amount_off: 32.00,
                percentage: true,
                merchant_id: @merchants[0].id,
                active: true
                }

                headers = { "CONTENT_TYPE" => "application/json" }
                post api_v1_merchant_coupons_path(@merchants[0].id), headers: headers, params: JSON.generate(coupon: coupon_params)

                expect(response).to_not be_successful
                data = JSON.parse(response.body, symbolize_names: true)

                expected = {
                    errors: "duplicate key value violates unique constraint \"index_coupons_on_code\"",
                    message: "Key (code)=(BOGO20202) already exists."
                }
                expect(data).to eq(expected)
            end

            it "only allows five codes to be active at one time" do
                @merchant4_coupons = create_list(:coupon, 5, active: true, merchant_id: @merchants[3].id)

                coupon_params = {name: "BOGO256",
                code: "BOGO20202",
                amount_off: 42.00,
                percentage: false,
                merchant_id: @merchants[3].id,
                active: true
                }

                headers = { "CONTENT_TYPE" => "application/json" }
                post api_v1_merchant_coupons_path(@merchants[0].id), headers: headers, params: JSON.generate(coupon: coupon_params)

                expect(response).to_not be_successful
                data = JSON.parse(response.body, symbolize_names: true)

                expected = {
                    errors: ["Too many active coupons"],
                    message: "Your coupon could not be created"
                }
                expect(data).to eq(expected)
            end

            it "doesn't allow incomplete coupons to be created" do
                coupon_params = {name: "BOGO265",
                code: "BOGO20202",
                amount_off: 32.00,
                percentage: true,
                merchant_id: @merchants[0].id,
                active: true
                }

                headers = { "CONTENT_TYPE" => "application/json" }
                post api_v1_merchant_coupons_path(@merchants[0].id), headers: headers, params: JSON.generate(coupon: coupon_params)

                expect(response).to_not be_successful
                data = JSON.parse(response.body, symbolize_names: true)

                expected = {
                    errors: "duplicate key value violates unique constraint \"index_coupons_on_code\"",
                    message: "Key (code)=(BOGO20202) already exists."
                }
                expect(data).to eq(expected)
            end
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
            expect(coupon[:data][:attributes][:active]).to eq "Active"
        end

        it "successfully runs route to deactivate coupon" do
            coupon_params = {active: false
            }

            headers = { "CONTENT_TYPE" => "application/json" }
            patch api_v1_merchant_coupon_path(@merchants[0].id, @merchant1_coupons[1].id), headers: headers, params: JSON.generate(coupon: coupon_params)
            
            expect(response).to be_successful
            coupon = JSON.parse(response.body, symbolize_names: true)
            expect(coupon[:data][:attributes][:active]).to eq "Inactive"
        end
    end

    after (:all) do
        Merchant.destroy_all
    end
end

# RSpec.describe Api::V1::Merchants::CouponsController, type: :controller do
#     it do
#         should rescue_from(ActiveRecord::RecordNotFound).with(:not_found_response)
#     end
# end
