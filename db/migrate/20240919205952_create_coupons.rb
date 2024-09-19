class CreateCoupons < ActiveRecord::Migration[7.1]
  def change
    create_table :coupons do |t|
      t.string :name
      t.boolean :percentage
      t.boolean :active
      t.float :amount_off
      t.references :merchant, foreign_key: true, null: false

      t.timestamps
    end
  end
end
