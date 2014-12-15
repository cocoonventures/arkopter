# 
#                                 Copyright © 2014- Michael Kahlil Madison II. 
#

# I was going to name this Bill Shido after the lego messenger ninja
# but it was perhaps going to far.
class CargoNinja

	include Sidekiq::Worker

	sidekiq_options queue: "cargo", backtrace: true
	sidekiq_options retry: true

	def perform(kopter_id, order_id=nil)
		@arkopter 	= QuadArkopter.find(kopter_id)
		# order_id	= @arkopter.current_order if order_id.empty?
		@order 		= Order.find(order_id)
		logger.info {"Received #{@arkopter.name} carrying Order \##{@order.id}"}
		@arkopter.status = "en-route"
		@arkopter.save
	rescue ActiveRecord::RecordNotFound => e
		logger.debug 	"CargoNinja finding problem trying to get kopter\#(#{kopter_id}) and " +
						"order\##{order_id} (which is nil by default because we can derive it"
	rescue
		logger.debug "CargoNinja fighting Confucius, no idea what happened!"
	else
		deliver_order
		redeploy_arkopter
	end

	def deliver_order
		logger.info {"#{@arkopter.name} cleared for delivery. Order \##{@order.id} in tow. Over."}
		ActiveRecord::Base.transaction do 			
			@arkopter.deliver
			@order.trickle_down_status("delivered")
			@order.save
		end
	rescue
		logger.debug { "[CargoNinja]: problem delivering order #{@order.id}, kopter #{@arkopter.id}, job #{@order.job_id}" }
	else
		logger.info {"#{@arkopter.name} reporting delivery success. Standby for redeployment. Waiting for Order \##{@order.id} clearance. Over."}
	end

	# skipping the status of in-redeployment for now 
	# presently after delivey kopters are immediately available
	# I didn't want to implement yet another queue for redeployment
	def redeploy_arkopter
		logger.info {"Mission Control to #{@arkopter.name} commence redeployment. Order \##{@order.id} is clear. Over and out!"}
		@arkopter.transaction do
			@arkopter.status = "ready"
			@arkopter.save!
		end 
	rescue
		logger.debug {"Problem redeploying QuadArkopter #{@arkopter.id}"}
	end

end