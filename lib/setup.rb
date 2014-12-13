
module Setup
	VERSION = "0.0.1"

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

end