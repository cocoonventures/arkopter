# 
#                                 Copyright © 2012-13 Michael Kahlil Madison II. 
#

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
	def get_availability(name)
		lock_name 	= "#{name}_inventory"
		inv 		= nil

		Sidekiq.redis do |connection|
			Redis::Semaphore.new("#{lock_name}", redis: connection) do
				inv = connection.hget("inventory", name)
			end
		end
		# special_sauce can go here if inv.present?
	end

	# async set inventory availability
	def set_availability(name,value)
		lock_name = "#{name}_inventory"
		Sidekiq.redis do |connection|
			Redis::Semaphore.new("#{lock_name}", redis: connection) do # product level lock
				if connection.hset("inventory", name, value) and value > 0
					# connection.hset("inventory", "#{name}_available", true)
				end
			end
		end
	end
	
end