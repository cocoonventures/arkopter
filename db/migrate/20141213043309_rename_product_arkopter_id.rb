class RenameProductArkopterId < ActiveRecord::Migration
  def change
  	rename_column :products, :arkopter_id, :quad_arkopter_id
  end
end
