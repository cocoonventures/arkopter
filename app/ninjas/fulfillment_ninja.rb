# 
#                                 Copyright © 2012-13 Michael Kahlil Madison II. 
#

class FulfillmentNinja

	include Sidekiq::Worker

	sidekiq_options queue: "inventory", backtrace: true
	sidekiq_options retry: true

	

	def perform(action, *arguments)
		@options = arguments.last.is_a?(Hash) ? arguments.pop : {}
		@collections = @options['collections'] or ""

		if @options.present? and @options.has_key?('target')
			permalink = action
			case
			when @options['target'] == "vc_firm"
				financial_organization_worker(permalink)
			when @options['target'] == "company"
				company_worker(permalink)
			end
		elsif self.class.method_defined?(action) or self.class.private_method_defined?(action)
			if options.has_key?('arguments')
				self.send(action,*arguments)
			else
				self.send(action)
			end
		end
	end 

	def financial_organization_worker(permalink)
		grab_and_store_financial_organization(permalink,set_entity: true)
		extract_and_save_components
	end

	def company_worker(permalink)
		grab_and_store_company(permalink,set_entity: true)
		extract_and_save_components
	end
	
	def dump_companies_to_csv(base_filename="output.csv", batch_size=500, options={})
		output = Rails.root + "log/" + [Time.now.strftime("%Y%m%d-%H%M"), base_filename].join('_')
		File.open(output, 'w') do |f|
			str = ["ID", "Company Name", "Description", "Homepage URL", "Blog URL", "Overview", "Tags"].join('|')
			f.puts str
			Company.all.find_in_batches(batch_size: batch_size) do |group|
				group.each do |company|
					overview = (company.overview.present?) ? Sanitize.clean(company.overview).gsub("\n"," ") : ""
					str = [	company.id, company.name, company.description, company.homepage_url,
							company.blog_url, overview, company.tag_list.join(',')].join('|')
					f.puts str
				end
			end			
		end
	end

	private

	# def extract_and_save_components
	# 	extract_financial_organization	
	# 	if @entity.save
	# 		extract_and_save_investments
	# 		extract_and_save_relationships
	# 		extract_and_save_milestones
	# 		extract_and_save_funds
	# 		extract_and_save_tags
	# 		return @entity
	# 	end
	# 	return nil
	# end

	def extract_and_save_components(cb_entity=nil, entity=nil)
		cb_entity = @cb_response if cb_entity.blank?
		entity = @entity if entity.blank? 			
		if entity.present? and entity.persisted?
			extract_and_save_investments(cb_entity,entity)
			extract_and_save_relationships(cb_entity,entity)
			extract_and_save_milestones(cb_entity,entity)
			extract_and_save_funds if @entity.class == FinancialOrganization
			extract_and_save_tags(cb_entity,entity)
			return @entity
		end
	end

	def extract_and_save_investments(cb_entity=nil, entity=nil)
		cb_entity = @cb_response if cb_entity.blank?
		entity = @entity if entity.blank? 
		cb_entity.investments.each do |inv|
			company = grab_and_store_company(inv.company_permalink, try_db_1st: true, update: true) 
			if company.present? and company.persisted?
				entity.investments.create(	
					funding_series: 				inv.funding_round_code, 		
					funding_source_url: 			inv.funding_source_url,
					funding_source_description: 	inv.funding_source_description, 
					amount_raised: 					inv.raised_amount,
					currency: 						inv.raised_currency_code,		
					funded_year: 	 				inv.funded_year, 
					funded_month:      				inv.funded_month,				
					funded_day: 					inv.funded_day,
		 			company: 						company
				)
			end
		end
		
	end

	def grab_and_store_financial_organization(permalink, options={})
		financial_organization = ( options[:try_db_1st] ) ? FinancialOrganization.where(cb_permalink: permalink).take : nil
		if financial_organization.present?
			return financial_organization
		else 
			fo = Crunchbase::FinancialOrganization.get(permalink)
			@cb_response = fo if options[:set_entity]
		end 
	rescue 
		nil
	else
		financial_org = FinancialOrganization.create(	
			name: 					fo.name, 				
			description: 			fo.description,
			email: 					fo.email_address, 		
			phone_number: 			fo.phone_number,
			overview: 				fo.overview, 			
			twitter_id: 			fo.twitter_username,
			number_of_employees: 	fo.number_of_employees,	
			homepage_url: 			fo.homepage_url,
			blog_url: 				fo.blog_url,				
			blog_feed_url: 			fo.blog_feed_url,
			category_id: 			nil,						
			cb_permalink: 			fo.permalink,
			cb_created_at: 			fo.created_at,			
			cb_updated_at: 			fo.updated_at
		)
		extract_and_save_tags(fo,financial_org)
		@entity = financial_org if options[:set_entity]
		return financial_org
	end


	def grab_and_store_company(permalink, options={})
		company = ( options[:try_db_1st] ) ? Company.where(cb_permalink: permalink).take : nil

		if company.present?
			return company
		else
			begin 
				co = Crunchbase::Company.get(permalink)
				@cb_response = co if options[:set_entity]
			rescue 
				nil
			else
				begin
					company = Company.create!(
						name: 					co.name, 
						description: 			co.description,		
						email: 					co.email_address,
						phone_number: 			co.phone_number,	
						overview: 				co.overview,
						twitter_id: 			co.twitter_username,
						number_of_employees: 	co.number_of_employees,
						homepage_url: 			co.homepage_url,	
						blog_url: 				co.blog_url,
						blog_feed_url: 			co.blog_feed_url,	
						category_id: 			nil,
						cb_permalink: 			co.permalink,		
						cb_created_at: 			co.created_at,
						cb_updated_at: 			co.updated_at
					)
				rescue
					# when worker pool is large enough progress happens fast enough where between entering
					# this method and this location, the company has been written to the database by another
					# as a result, by the time it got here saving throws an exception.  when that happens
					# it probably exists in the database, so grab is and return
					company = ( options[:try_db_1st] ) ? Company.where(cb_permalink: permalink).take : nil
					return company
				end

				if company.persisted?
					extract_and_save_tags(co,company) if co.tags.present?
					extract_and_save_milestones(co,company) if co.milestones.present?
					UpdateWorker.perform_async(co.permalink, target: 'company') if options[:update]	
				end 

				@entity = company if options[:set_entity]
				return company
			end
		end 
	end

	def extract_and_save_relationships(cb_entity=nil, entity=nil)
		cb_entity = @cb_response if cb_entity.blank?
		entity = @entity if entity.blank? 
		cb_entity.relationships.each do |rel|
			if rel.class == Crunchbase::PersonRelationship
				person = Person.where(cb_permalink: rel.person_permalink).take
				if person.blank?
					begin
						p = Crunchbase::Person.get(rel.person_permalink)
					rescue
						p = nil
					else
						person = Person.create(
							first_name: 	p.first_name, 
							last_name: 		p.last_name,
							email: 			nil,
							cb_permalink: 	p.permalink,
							cb_url: 		p.crunchbase_url,
							homepage_url: 	p.homepage_url,
							blog_url: 		p.blog_url,
							blog_feed_url: 	p.blog_feed_url,
							birthplace: 	p.birthplace,
							twitter_id: 	p.twitter_username,
							overview: 		p.overview
						)
						extract_and_save_tags(p,person) 		if p.tags.present?
						extract_and_save_investments(p,person) 	if p.investments.present?
						extract_and_save_milestones(p,person) 	if p.milestones.present?
					end
				end
				if person.present? and person.persisted?
					fo_rel = entity.relationships.create(
						title: 			rel.title,
						is_active: 		(rel.current?),
						person: 		person
					)
				end
			end
		end
	end

	def extract_and_save_milestones(cb_entity=nil, entity=nil)
		cb_entity = @cb_response if cb_entity.blank?
		entity = @entity if entity.blank?
		debugger if (!entity.persisted? or entity.blank?)
		entity.save if !(entity.persisted?)
		cb_entity.milestones.each do |stone|
			entity.milestones.create(
				description: 		stone.description,
				stoned_year: 		stone.stoned_year, 
				stoned_month: 		stone.stoned_month, 
				stoned_day: 		stone.stoned_day,
				source_url: 		stone.source_url,
				source_text: 		stone.source_text,
				source_description: stone.source_description
			)
		end if entity.present?
	end

	def extract_and_save_funds(cb_entity=nil, entity=nil)
		cb_entity = @cb_response if cb_entity.blank?
		entity = @entity if entity.blank? 
		cb_entity.funds.each do |fund|
		end
	end

	def extract_and_save_tags(cb_entity=nil, entity=nil, options={})
		cb_entity = @cb_response if cb_entity.blank?
		entity = @entity if entity.blank? 
		if cb_entity.tags.present?
			unless options[:multiple_insert]
				difference_array = cb_entity.tags - entity.tag_list
				entity.tag_list.add(difference_array) 				# only add tags not already there
			else
				entity.tag_list.add(cb_entity.tags)					# add redundant tags to boost the count
			end
			entity.save
		end
		entity.collection_list.add(@collections) if @collections.present?
	end
	
end

# ---------------------------------- Data we will need to do something with later
		# ------------------------------------------------------These are items I don't yet handle
     	#@crunchbase_url = json['crunchbase_url']
      	#@founded_year = json['founded_year']
      	#@founded_month = json['founded_month']
      	#@founded_day = json['founded_day']
      	#@alias_list = json['alias_list']
      	#@image = Image.create(json['image'])
      	#@offices = json['offices']
      	#@providerships_list = json["providerships"]
      	#@funds = json['funds']
      	#@video_embeds = json['video_embeds']
      	#@external_links = json['external_links']

 		# ------------------------------------------------------These may need some massaging
 		#@created_at = DateTime.parse(json["created_at"])
      	#@updated_at = DateTime.parse(json["updated_at"])
