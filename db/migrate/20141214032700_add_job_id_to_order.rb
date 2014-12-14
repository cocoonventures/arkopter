class AddJobIdToOrder < ActiveRecord::Migration
  def change
    add_column :orders, :job_id, :string, default: nil
  end
end
