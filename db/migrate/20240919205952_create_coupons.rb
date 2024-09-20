class CreateCoupons < ActiveRecord::Migration[7.1]
    def change
        create_table :coupons do |t|
            t.string :name, null: false
            t.string :code, null: false
            t.boolean :percentage
            t.boolean :active
            t.float :amount_off, null: false
            t.references :merchant, foreign_key: true, null: false

            t.timestamps
        end

        add_index :coupons, :code, unique: true
    end
end
