
require 'sketchup.rb'
require 'Phlatboyz/Constants.rb'

class TabTool
	@@nCursor = 0
	def initialize
	    @ip = nil
		
		@ipoint1 = nil
		@ipoint2 = nil
		
		@valid_edge = false
		
		#@circle_normal = Geom::Vector3d.new 0,0,1
		#@circle_radius = 0.25.inch
		#@drawn = false
		#@@current_tab_width = Sketchup.active_model.get_attribute $dict_name, $dict_tab_width, $default_tab_width
		
		if(@@nCursor == 0)
			cursorPath = Sketchup.find_support_file($cursor_tab_tool, $cursor_directory)
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
	    Sketchup::set_status_text "TabTool Activated", SB_VCB_LABEL
	    self.reset(nil)
	end

	def reset(view)
	    if(view)
	        view.tooltip = nil
	        view.invalidate #if @drawn
	    end
	end

	def onMouseMove(flags, x, y, view)
		@ip.pick view, x, y
		pointArray = tabPointsFromInputPoint(@ip)
		if(@valid_edge)
			@ipoint1 = pointArray[0]
			@ipoint2 = pointArray[1]

			view.tooltip = @ip.tooltip
			#Sketchup::set_status_text @ip.tooltip, SB_VCB_LABEL
		end
		view.invalidate if(@ip.display?)
	end

	def onLButtonDown(flags, x, y, view)
		@ip.pick view, x, y
		pointArray = tabPointsFromInputPoint(@ip)
		if(@valid_edge)
			self.create_geometry(pointArray, view)
		end
		self.reset(view)
	    # Clear any inference lock
	    view.lock_inference
		Sketchup::set_status_text "tab complete", SB_VCB_LABEL
	end

	def draw(view)
		if(@valid_edge)
			self.draw_geometry(@ipoint1, @ipoint2, view)
		end
	end

	def tabPointsFromInputPoint(inputPoint)
		e = inputPoint.edge

		pointArray = nil
		@valid_edge = false
		if(e != nil)
			edgeType = e.get_attribute $dict_name, $dict_edge_type
			if(edgeType == $key_inside_cut || edgeType == $key_outside_cut)
				@valid_edge = true
				current_tab_width = Sketchup.active_model.get_attribute $dict_name, $dict_tab_width, $default_tab_width

				ep1 = e.start.position
				ep2 = e.end.position

				if e.length < current_tab_width
					# The edge width is smaller than the tab width - just use the entire edge
					point1 = ep1
					point2 = ep2
				else
					# When the tab is smaller than the edge then use the input point as center
					v = ep1.vector_to ep2 
					pt = inputPoint.position
					half = current_tab_width/2
					point1 = pt.offset(v, -half)
					point2 = pt.offset(v, half)
					# if one of the tab end points goes past the edge end, then use the edge end point
					point1 = ep1 if pt.distance(ep1) < half
					point2 = ep2 if pt.distance(ep2) < half
				end
				pointArray = Array[point1, point2]
			end
		end
		return pointArray
	end

	# Draw the geometry
	def draw_geometry(pt1, pt2, view)
		view.drawing_color = $color_tab_drawing
		#view.line_stipple = "---.---"
		view.line_width = 6.0
	    view.draw_line(pt1, pt2)
	end

	def create_geometry(pointArray, view)
		model = view.model
		entities = model.entities
		#Sketchup::set_status_text "create_geometry", SB_VCB_LABEL
		#pointArray = tabPointsFromInputPoint(inputPoint)
		if(@valid_edge)
			model.start_operation "Creating Tab"
			newedge = entities.add_line pointArray[0], pointArray[1]
			
			newedge.set_attribute $dict_name, $dict_cut_depth_factor, get_tab_depth_factor()/100.0
			newedge.set_attribute $dict_name, $dict_edge_type, $key_tab_cut
			newedge.material = $color_tab_cut

			model.commit_operation
		    Sketchup::set_status_text "Tab Created", SB_VCB_LABEL
		end
	end

end
