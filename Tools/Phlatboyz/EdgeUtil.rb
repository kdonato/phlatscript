require 'sketchup.rb'
require 'Phlatboyz/Constants.rb'

class EdgeUtil
 
	def EdgeUtil.walkEdges(in_edge, in_max = nil)
		allEdges = Array.new
		begin
			edgeArrayStart = Array.new
			_iterateAndCollectEdges(in_edge, edgeArrayStart, true, in_max)
			allEdges += edgeArrayStart.reverse!

			allEdges << in_edge

			edgeArrayEnd = Array.new
			_iterateAndCollectEdges(in_edge, edgeArrayEnd,  false, in_max)
			allEdges += edgeArrayEnd
		rescue
			UI.messagebox "Exception in EdgeUtil.EdgeUtils "+$!
		end
		return allEdges
	end

	private
	
	def EdgeUtil._iterateAndCollectEdges(in_edge, in_edgeArray, in_back, in_max)
		connectingEdge = getConnectingEdge(in_edge, in_back)
		if connectingEdge != nil
			if not in_edgeArray.include?(connectingEdge)
				if in_max == nil || in_edgeArray.length < in_max
					in_edgeArray << connectingEdge
					_iterateAndCollectEdges(connectingEdge, in_edgeArray, in_back, in_max)
				end
			end
		end
	end
	
	def EdgeUtil.getConnectingEdge(in_edge, in_back)
		if in_edge == nil
			return nil
		end

		vertex = in_back ? in_edge.start : in_edge.end
		edges = vertex.edges
		edges -= [in_edge]
		if edges.empty? 
			return nil
		end
		
		# Don't return any edge that has an edge type defined
		# Note dependency on globals here
		edgeType = edges[0].get_attribute $dict_name, $dict_edge_type
		if(edgeType != nil)
			return nil
		end
		return edges[0]
	end
end