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

	# hash_key 	:inventory 
	lock 		:inventory_lock

	has_many 	:products

	def sync_inventory
		# @inv = Redis::HashKey.new('inventory') if !@inv.empty?
		# Redis::Lock.new("#{name}_inventory") do 							#, :expiration => 15, :timeout => 0.1)   #self.inventory_lock.lock do
		# 	#@inv = Redis::HashKey.new('inventory') 							# not necessary, but safe
		# 	self.inventory["#{self.name}"]
		# end
		# self.quantity = @inv[self.name]										# release lock first
		self.quantity = inventory["#{self.name}"]

	end 

	def set_inventory(value=nil)
		# debugger
		value = self.quantity if value.blank?
		# debugger
		
		# self.inventory_lock.lock do 										# prefer over Redis::Semaphore.new("", redis: self.redis) do
		# Redis::Lock.new("#{self.name}_inventory").lock do
		StockItem.obtain_lock("inventory_lock",self.id) do
			@inv = Redis::HashKey.new('inventory') if @inv.blank?
			@inv[self.name] = value if value.present?
			#inventory["#{self.name}"] = value if value.present?
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
				self.save # can pull this out of the loop later to optimize (?)
			end
		end
		set_inventory(self.quantity)
	end

	private

	# def inv
	# 	@inv = Redis::HashKey.new('inventory') if @inv.empty?
	# end

	# def inv=()

	# end
end
