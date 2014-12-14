# 
#                                 Copyright © 2012-13 Michael Kahlil Madison II. 
#

class PigeonNinja

	include Sidekiq::Worker

	sidekiq_options queue: "messages", backtrace: true
	sidekiq_options retry: true

	def perform(*args)
	end	
end