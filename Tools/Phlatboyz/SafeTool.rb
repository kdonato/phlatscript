
require 'sketchup.rb'
require 'Phlatboyz/Constants.rb'

class SafeTool

	@@nCursor = 0
	def initialize
	    #@ip = nil
		
		@point_array = Array.new(5)
		
		if(@@nCursor == 0)
			cursorPath = Sketchup.find_support_file($cursor_safe_tool, $cursor_directory)
			if cursorPath
				@@nCursor = UI.create_cursor(cursorPath, 12, 14)
			end	
		end
	end

	def onSetCursor()
		cursor = UI.set_cursor(@@nCursor)
	end

	def activate
	    #@ip = Sketchup::InputPoint.new
	    Sketchup::set_status_text "SafeTool Activated", SB_VCB_LABEL
	    self.reset(nil)
	end

	def reset(view)
	    if(view)
	        view.tooltip = nil
	        view.invalidate
	    end
	end
	
	def onMouseMove(flags, x, y, view)
		ip = view.inputpoint x, y
		safeArrayFromInputPoint(ip)

		#Sketchup::set_status_text "pt="+@point_array[0].to_s, SB_VCB_LABEL
		view.invalidate
	end

	def onLButtonDown(flags, x, y, view)
		ip = view.inputpoint x, y
		safeArrayFromInputPoint(ip)
		self.create_geometry(view)
		self.reset(view)
	    # Clear any inference lock
	    view.lock_inference
		#Sketchup::set_status_text "fold complete", SB_VCB_LABEL
	end

	def safeArrayFromInputPoint(inputPoint)
		safe_array = get_safe_array()
		w = safe_array[2]
		h = safe_array[3]
		area_point3d_array = _get_area_point3d_array(inputPoint.position.x, inputPoint.position.y, w, h)
		@point_array = area_point3d_array
		@point_array[4] = @point_array[0]
	end

	def draw(view)
		self.draw_geometry(view)
	end

	# Draw the geometry
	def draw_geometry(view)
		view.drawing_color = $color_safe_drawing
		view.line_stipple = "."
		#@ip.draw view
		view.draw_polyline @point_array
	end
	
	def create_geometry(view)
		model = view.model
		entities = model.entities

		model.start_operation "Creating Safe Area"
		
		x0 = @point_array[0].x
		y0 = @point_array[0].y
		w = @point_array[0].distance @point_array[1]
		h = @point_array[0].distance @point_array[3]
		
		set_safe_array(x0, y0, w, h, model)
		draw_safe_area(model)
		
		model.commit_operation
	    #Sketchup::set_status_text "Fold Created", SB_VCB_LABEL
		Sketchup.send_action "selectSelectionTool:"
		
	end
	
end