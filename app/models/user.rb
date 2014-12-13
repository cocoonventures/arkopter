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
	has_many :products, through: :orders

	def make_order(product_hash)
		unless product_hash.present?
			order = self.orders.create!()
			product_hash.each do |product,quantity|
				# self.
			end
		end
	end
end
