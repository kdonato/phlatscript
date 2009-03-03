
require 'sketchup.rb'
require 'Phlatboyz/Constants.rb'

class PlungeTool
	@@nCursor = 0
	@@D = 1 # Depth Factor Index
	@@override_factor = 0
	@saved_edge_array = Array.new	
	
	def initialize
		@ip = nil
		
		if(@@nCursor == 0)
			cursorPath = Sketchup.find_support_file($cursor_plunge_tool, $cursor_directory)
			if cursorPath
				@@nCursor = UI.create_cursor(cursorPath, 13, 16)
			end	
		end
	end

	def onSetCursor()
		cursor = UI.set_cursor(@@nCursor)
	end

	def activate
		@ip = Sketchup::InputPoint.new
		self.reset(nil)
	end
	
	def reset(view)
	    if(view)
	        view.tooltip = nil
	        view.invalidate
	    end
	end

	def onMouseMove(flags, x, y, view)
		@ip.pick view, x, y
		view.invalidate if(@ip.display?)
	end
	
	def onLButtonDown(flags, x, y, view)
		@ip.pick view, x, y
		edgeArray = plungeEdgesFromInputPoint(@ip)	
		@saved_edge_array = edgeArray
		self.Create_Geometry(view, x, y)
		
		self.reset(view)
	    # Clear any inference lock
	    view.lock_inference
	end

	def draw(view)
		# Note: dont do anything in here that modifies the model
		if(@valid_edge)
			self.draw_geometry(view)
		end
	end

	def plungeEdgesFromInputPoint(inputPoint)
		edgeArray = Array.new
		e = inputPoint.edge
		@valid_edge = false
		if e != nil
			edgeType = e.get_attribute $dict_name, $dict_edge_type
			if(edgeType == nil)
				@valid_edge = true
				begin
					edgeArray = EdgeUtil.walkEdges(e)
				rescue
					UI.messagebox "Exception in PlungeTool.plungeEdgesFromInputPoint "+$!
				end
			end
		end
		return edgeArray
	end

	
	#TODO move this? Also in FoldTool
	

	# Draw the geometry
	def draw_geometry(view)
		view.drawing_color = $color_plunge_cut
		view.line_width = 3.0
		begin
			if not @saved_edge_array.empty?
				#UI.messagebox "length="+@saved_edge_array.length.to_s+" "+@saved_edge_array.inspect
				@saved_edge_array.each do | e |
					#view.draw_line(e.start.position, e.end.position)
					view.draw_line(e.start.position, e.end.position)
				end
			end
		rescue
			UI.messagebox "Exception in PlungeTool.draw_geometry "+$!
		end
	end

	def Create_Geometry(view, x, y)
		model=view.model
		entities=model.entities
		view.line_width = 3.0
		model.start_operation "Creating Plunge Circle"
		ip = Sketchup::InputPoint.new
		ip.pick(view,x,y)
		view.drawing_color = $color_plunge_cut
		@diam=Sketchup.active_model.get_attribute $dict_name, $dict_bit_diameter, $default_bit_diameter
		vectz=Geom::Vector3d.new(0,0,1)###Z+
		radius=@diam ### diameter of the bit


		newedge = entities.add_line([ip.position[0],ip.position[1],0],[ip.position[0]+radius/2,ip.position[1],0])
		set_phlatboyz_edges([newedge], $key_plunge_cut, true, $color_plunge_cut)		


		group=entities.add_group
		gentities=group.entities
		circleInner=gentities.add_circle(ip.position,vectz,(radius/2))
		gentities.add_face(circleInner)
		

		model.commit_operation
	end


end
