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

	# orders are made with a product hash where key=stock_item name and
	# value=quantity being purchased
	def make_order(product_hash)
		order = self.orders.create!(status: "processing") 				# no locking needed when creating an order
	rescue
		logger.debug 	"User.make_order can't make an order -- " +
						"pretty useless, go fix some crap!"
		false
	else
		order.pick_n_pull(product_hash)
		order.fulfill_me 												# this is asynchronous
		true
	end
end
