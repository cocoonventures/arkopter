class CreateStockItems < ActiveRecord::Migration
  def change
    create_table :stock_items do |t|
      t.string :name
      t.integer :quantity
      t.decimal :price, precision: 6, scale: 2

      t.timestamps
    end
  end
end
