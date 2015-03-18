class Item < ActiveRecord::Base

	def self.search(search, typeid, andor)
		#where("title like?", "%#{search}%")
		where(type_id: typeid )
	end

	belongs_to :type

end

