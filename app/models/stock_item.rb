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
	#  TODO: make inventory set and sync asynchronous here not just from Sidekiq
	include 	Redis::Objects
	lock 		:inventory_lock
	has_many 	:products

	def sync_inventory
		@inv 			= Redis::HashKey.new('inventory') if @inv.blank?
		self.quantity 	= @inv[self.name]										# self.quantity = inventory["#{self.name}"]
	end 

	def set_inventory(value=nil)
		value = self.quantity if value.blank?

		StockItem.obtain_lock("inventory_lock",self.id) do 					# prefer over Redis::Semaphore.new("", redis: self.redis) do
			@inv 			= Redis::HashKey.new('inventory') if @inv.blank?
			@inv[self.name] = value if value.present?
		end
	end	

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
			else
				self.quantity += 1
			end
		end
		self.save
		set_inventory
	end

	private

	def set_availabilty_async
		AbacusNinja.perform_async("set_availabilty",{arguments: [self.name, self.quantity]})
	end

	def get_availabilty_async
		AbacusNinja.perform_async("get_availabilty",{arguments: self.name}) 
	end

	def available?
		sync_inventory # non-async
		return (self.quantity > 0)
	end
end
