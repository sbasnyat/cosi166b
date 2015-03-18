class Item < ActiveRecord::Base

	def self.search(search, typeid, andor)

		if search ==nil && typeid == nil then
			nil
		elsif search == nil then
			where("type_id like?", "%#{typeid}%")
		elsif typeid == nil then 
			where("title like?", "%#{search}%")			
		else
			query = [ "title like ?" ]
			query.push(andor)
			query.push("type_id like ?")
			where(query.join(' '), "%#{search}%", "%#{typeid}%")
		end
		
		
	end

	belongs_to :type

end


