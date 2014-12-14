# 
#                                 Copyright © 2014- Michael Kahlil Madison II. 
#


# deprecate if I have time
class AbacusNinja
	include Sidekiq::Worker

	sidekiq_options queue: "availability", backtrace: true
	sidekiq_options retry: true

	def perform(action, *arguments)
		@options = arguments.last.is_a?(Hash) ? arguments.pop : {}
		# @collections = @options['collections'] or ""

		if self.class.method_defined?(action) or self.class.private_method_defined?(action)
			if arguments.size > 0
				self.send(action,*arguments)	
			else
				self.send(action) # avoid wrong number arguments potential
			end
		end
	end

	private

	# You said getting avaialbility is non-trivial so this is the async
	# way of getting availability of inventory, if you want where I have
	# "special_sauce" comment, you can do something cool with inv (send an email or report)
	# on the models I make a seperate connection with Redis for pulling 
	# inventory in a way that shouldn't take forever.
	def get_availability(name, sync_back=true)
		lock_name 	= "#{name}_inventory"
		inv 		= nil

		Sidekiq.redis do |connection|
			Redis::Semaphore.new("#{lock_name}", redis: connection) do
				inv = connection.hget("inventory", name)
			end
		end
		# special_sauce can go here if inv.present?
		return sync_back(name,inv) if sync_back and inv.present?
		true
	end

	# async set inventory availability
	# this is an option 
	def set_availability(name,value)
		lock_name = "#{name}_inventory"
		Sidekiq.redis do |connection|
			Redis::Semaphore.new("#{lock_name}", redis: connection) do 		# product level lock
				connection.hset("inventory", name, value)
			end
		end
	end

	def sync_back(name, new_inventory_level)
		stock_item 		= StockItem.where(name: name).take!
		stock_item.transaction do
			stock_item.update_attribute!(quantity: new_inventory_level)
		end
	rescue
		logger.debug 	"Problem finding StockItem #{name} in DB, unable to sync back from Redis"
		false
	else 
		logger.info		"Sync'd db inventory with ninja/worker realtime data"
		true
	end
	
end