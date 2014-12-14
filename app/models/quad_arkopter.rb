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


end
