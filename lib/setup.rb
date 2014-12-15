
module Setup
	VERSION = "0.0.1"

	# I needed something to generate objects while working in the console
	# until background processing was up and running so I used this module
	# quick and dirty

	def self.add_bobbleheads(quantity=50)
		["Ari-Bobblehead", "Ryan-Bobblehead", "Andrew-Bobblehead"].each do |p|
			begin
				item = StockItem.create!(name: p, quantity: 0, price: 19.99)
			rescue
				logger.debug "problem creating bobbleheads moving along..."
			else
				item.stock_warehouse(name_prefix: p, status: "warehoused",quantity: quantity)
			end
		end
	end

	def self.add_quad_arkopters(quantity=10,prefix="AirWolf")
		padding = 6
		for kopter_count in 1..quantity do
			kopter_name = prefix + kopter_count.to_s.rjust(padding,'0')
			begin
				QuadArkopter.create!(name: kopter_name, status: "ready")
			rescue
				logger.debug {"Problem creating QuadArkopters"}
			end
		end
	end

	def self.add_users(quantity=100,prefix="ProductUser")
		padding = 6
		for user_count in 1..quantity do
			user_name = prefix + user_count.to_s.rjust(padding,'0')
			begin
				User.create!(name: user_name)
			rescue
				logger.debug {"Problem creating Users"}
			end
		end
	end

	def self.make_orders(num_orders=5) 
		h = Hash.new
		StockItem.all.pluck(:name).each{|p| h[p] = num_orders }
		User.all.limit(100).each{|u| u.make_order(h) 	  }
	end

	def self.fulfill_orders
		Order.all.each{|o| o.fulfill_me}
	end

	def self.cancel(status="processing")
		Order.where(status: status).each {|o| o.cancel_me}
	end

	def self.clear_database
		User.delete_all
		Order.delete_all
		Product.delete_all
		QuadArkopter.delete_all
		StockItem.delete_all
	end

	def self.populate
		clear_database
		add_users
		add_bobbleheads
		add_quad_arkopters
		# make_orders
	end
	def self.make_one_order
		u = User.first
		s = StockItem.first
		u.make_order({s.name => s.quantity})
	end
	def self.populate_and_make_orders
		clear_database
		populate
		make_orders
	end
end