module ArkopterOperations
	module KopterStatus
		extend self
				
		STATUSES = ["ready", "reserved", "loaded-up", "en-route", "in-redeployment"].freeze	


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

		def ready?
			self.status == "ready"
		end
		def reserved?
			self.status == "reserved"
		end
		def loaded_up?
			self.status == "loaded-up"
		end
		def in_redeployment?
			self.status == "in-redeployment"
		end
	end
end