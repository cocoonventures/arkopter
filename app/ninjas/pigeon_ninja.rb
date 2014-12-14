# 
#                                 Copyright © 2014- Michael Kahlil Madison II. 
#

class PigeonNinja

	include Sidekiq::Worker

	sidekiq_options queue: "messages", backtrace: true
	sidekiq_options retry: true

	# Placeholder for messaging if I have time
	def perform(*args)
	end	
end