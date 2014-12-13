class CreateProducts < ActiveRecord::Migration
  def change
    create_table :products do |t|
      t.references :stock_item
      t.string :inventory_name
      t.string :status
      t.references :order
      t.references :arkopter

      t.timestamps
    end
  end
end
