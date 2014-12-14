# == Schema Information
#
# Table name: quad_arkopters
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  status     :string(255)
#  deliveries :integer          default(0)
#  created_at :datetime
#  updated_at :datetime
#

class QuadArkopter < ActiveRecord::Base
	has_many :orders

	include ArkopterOperations::KopterStatus
	
	def self.reserve
		arkopter = QuadArkopter.where(status: "ready").take!
	rescue ActiveRecord::RecordNotFound => e
		logger.debug "No QuadArkopters are ready!\nEX: #{e.message}"
		nil																# optionally may want to block
	rescue
		nil
	else
		arkopter.status = "reserved"
		arkopter.save
		return arkopter 												# this should probably be reserved by somthing trackable since I mark it reserved and return it
	end

	def current_delivery(order_limit=1)
		@current_order = self.orders.where(status: ["on-kopter","en-route"] ).take(order_limit)
	end

	# this should only be called from the ninja/worker 
	# for now delivery is just sleeping and returning true
	# but feels like it should belongs to the kopter
	def deliver_order
		sleep self.delivery_time.seconds 								# default time enforced by DB is 60 
		true
	end

end
