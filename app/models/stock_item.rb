# == Schema Information
#
# Table name: stock_items
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  quantity   :integer
#  price      :decimal(6, 2)
#  created_at :datetime
#  updated_at :datetime
#

class StockItem < ActiveRecord::Base

	has_many :products


	def stock_warehouse(options={})
		
		{
			name_prefix: 		"Arktos",
			status: 			"warehoused",
			quantity: 			1,
			name_padding: 		5
		}.merge!(options)

		options[:quantity].downto(1) do |i|
			begin
				p = self.products.create!(
					inventory_name: 	"%s%0#{options[:name_padding]}d" %[options[:name_prefix], i],
					status: 			options[:status]
				)
			rescue
				logger.debug "Problem creating adding inventory for #{name} item #{i}"
			end
			self.quantity += 1
			self.save
		end
	end
end
