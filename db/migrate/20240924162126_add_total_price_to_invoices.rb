class AddTotalPriceToInvoices < ActiveRecord::Migration[7.1]
  def change
    add_column :invoices, :total_price, :decimal, precision: 10, scale: 2, default: 0.00
  end
end
