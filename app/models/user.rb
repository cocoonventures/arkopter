# == Schema Information
#
# Table name: users
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  email      :string(255)
#  created_at :datetime
#  updated_at :datetime
#

class User < ActiveRecord::Base
	has_many :orders

	def make_order(product_hash)
		order = self.orders.create!(status: "processing")
	rescue
		logger.debug "User.make_order can't make an order -- pretty useless, go fix some crap!"
		false
	else
		order.fulfill_me
		true
	end
end
