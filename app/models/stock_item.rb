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

	include 	Redis::Objects
	lock 		:inventory_lock
	has_many 	:products

	# syncs inventory from Redis until I phase out
	def sync_inventory
		@inv 			= Redis::HashKey.new('inventory') if @inv.blank?		# new is a "new" connection to Redis, not new :)
		self.quantity 	= @inv[self.name]										# self.quantity = inventory["#{self.name}"]
	end 

	def set_inventory(value=nil)
		value = self.quantity if value.blank?

		StockItem.obtain_lock("inventory_lock",self.id) do 					# prefer over Redis::Semaphore.new("", redis: self.redis) do
			@inv 			= Redis::HashKey.new('inventory') if @inv.blank?
			@inv[self.name] = value if value.present?
		end
		self.transaction do
			self.quantity = value
			save!
		end if value != self.quantity
	rescue
		logger.debug {"Problem setting inventory to #{value}"}
	end	

	def stock_warehouse(opts={})
		
		options = {
			name_prefix: 		"Arktos",
			status: 			"warehoused",
			quantity: 			1,
			name_padding: 		5
		}
		options.merge!(opts)

		prefix  = options[:name_prefix]
		padding = options[:name_padding] or 5

		options[:quantity].downto(1) do |i|
			begin
				inventory_name = "%s%0#{padding}d" %[prefix, i]
						debugger
				p = self.products.create!(inventory_name: inventory_name, status: options[:status])
			rescue => e
				logger.debug "Problem creating adding inventory for #{name} item #{i}\n" +
							 "Inspect#{self.inspect}\n" +
							 "#{inventory_name.inspect}\n" +
							 "#{options.inspect}\n"
							 "#{e.message}\n#{e.backtrace.join("\n")}"
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
