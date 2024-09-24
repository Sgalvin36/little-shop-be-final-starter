class InvoiceItem < ApplicationRecord
    belongs_to :item
    belongs_to :invoice

    def update_total
        binding.pry
    end
end