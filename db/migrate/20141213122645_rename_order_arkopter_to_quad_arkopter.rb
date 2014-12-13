class RenameOrderArkopterToQuadArkopter < ActiveRecord::Migration
  def change
  	  	rename_column :orders, :arkopter_id, :quad_arkopter_id
  end
end
