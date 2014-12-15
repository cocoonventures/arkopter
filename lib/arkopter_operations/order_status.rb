module ArkopterOperations
	module OrderStatus
		extend self

		# note2self: don't use symbols, Sidekiq hates them, strings only
		STATUSES = ["warehoused","processing", "on-arkopter", "en-route", "delivered", "canceled"].freeze

		def status=(new_status)
			if valid_status?(new_status)
			  	super(new_status)
			else 
				logger.debug 	"Use a valid status: #{new_status} isn't in #{STATUSES.inspect}"
				self.status 	# return the old status
			end
		end

		def valid_status?(new_status)
			STATUSES.include?(new_status)
		end
		def on_arkopter?
			self.status == "on-arkopter"
		end
		def warehoused?
			self.status == "warehoused"
		end
		def processing?
			self.status == "processing"
		end
		def en_route?
			self.status == "en-route"
		end
		def delivered?
			self.status == "delivered"
		end
		def canceled?
			self.status == "canceled"
		end		
	end
end