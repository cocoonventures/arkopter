class CreateQuadArkopters < ActiveRecord::Migration
  def change
    create_table :quad_arkopters do |t|
      t.string :name
      t.string :status
      t.integer :deliveries, default: 0

      t.timestamps
    end
  end
end
