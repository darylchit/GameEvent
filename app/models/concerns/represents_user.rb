module RepresentsUser
	extend ActiveSupport::Concern

	#we're cheating here
	def find (getting_clever)
		return self.send(self.class.name.underscore)
	end
end


