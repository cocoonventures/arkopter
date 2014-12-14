
module Setup
	VERSION = "0.0.1"

	def Setup.add_bobbleheads(quantity=50)
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

	def Setup.add_quad_arkopters(quantity=10,prefix="AirWolf")
		padding = 6
		for kopter_count in 1..quantity do
			kopter_name = prefix + kopter_count.rjust(padding,'0')
			begin
				# QuadArkopter.create!()
			rescue
			else
			end
		end
	end
end