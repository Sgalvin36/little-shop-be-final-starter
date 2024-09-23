class Api::V1::Merchants::InvoicesController < ApplicationController
    before_action :set_merchant
    
    def index
        if params[:status].present?
            invoices = @merchant.invoices_filtered_by_status(params[:status])
        else
            invoices = @merchant.invoices
        end
        render json: InvoiceSerializer.new(invoices)
    end

    def show
        invoice = @merchant.invoices.find(params[:id])
        render json: InvoiceSerializer.new(invoice)
    end

    private

    def set_merchant
        if params.has_key?(:merchant_id) && params[:merchant_id] != ""
            @merchant= Merchant.find(params[:merchant_id])
        end
    end
end