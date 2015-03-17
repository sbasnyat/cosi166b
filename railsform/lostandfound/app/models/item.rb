class Item < ActiveRecord::Base

	def self.search(search)
		where("title like?", "%#{search}%")
	end

	belongs_to :type

end
