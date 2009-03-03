
require 'sketchup.rb'

class EdgeHolder
	@the_edge = nil
	@reversed = false
	def initialize(in_edge, in_reversed=false)
		@the_edge = in_edge
		@reversed = in_reversed
	end

	def startPosition(in_transform = nil)
		#UI.messagebox(@@the_edge)
		
		if(@reversed)
			point = @the_edge.end.position
		else
			point = @the_edge.start.position
		end
		point = point.transform in_transform if(in_transform != nil)
		return point
	end

	def endPosition(in_transform = nil)
		if(@reversed)
			point = @the_edge.start.position
		else
			point = @the_edge.end.position
		end
		point = point.transform in_transform if(in_transform != nil)
		return point
	end

	def reverse
		@reversed = ~@reversed
	end
	
	def edge
		return @the_edge
	end

	def getFactor 
		return @the_edge.get_attribute($dict_name, $dict_cut_depth_factor, 0.0)
	end
	
	
	def is_phlatboyz_edge(and_match_type=nil)
		is_edge = false
		if(@the_edge != nil)
			edgeType = @the_edge.get_attribute $dict_name, $dict_edge_type
			if(edgeType != nil)
				if and_match_type != nil
					is_edge = (and_match_type == edgeType)
				else
					is_edge = true
				end
			end
		end
		return is_edge
	end

	
end