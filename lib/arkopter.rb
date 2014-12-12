class Arkopter
	def deliver(delivery_time=0.seconds)
		
		# deliver the package

		# add 
		sleep(delivery_time) if delivery_time > 0.seconds # redo this as async 

		puts "Delivery Complete" 
	end
end
