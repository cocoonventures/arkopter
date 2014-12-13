class CreateOrders < ActiveRecord::Migration
  def change
    create_table :orders do |t|
      t.string :status
      t.references :user, index: true
      t.references :arkopter, index: true

      t.timestamps
    end
  end
end
