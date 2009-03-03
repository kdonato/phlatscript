
require 'sketchup.rb'
require 'Phlatboyz/Constants.rb'

class PlungeTool
	@@nCursor = 0
	
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
		self.reset(view)
		view.invalidate if(@ip.display?)
	end
	
	def onLButtonDown(flags, x, y, view)
		@ip.pick view, x, y
		self.create_geometry(view, x, y)
		
		self.reset(view)
	    # Clear any inference lock
	    view.lock_inference
	end

	def draw(view)
		# Note: dont do anything in here that modifies the model
		self.draw_geometry(view)
	end

	# Draw the geometry
	def draw_geometry(view)
		#UI.messagebox "draw_geometry"
		view.drawing_color = $color_plunge_cut
		view.line_width = 3.0
		begin

			x = @ip.position.x
			y = @ip.position.y

			radius = (Sketchup.active_model.get_attribute $dict_name, $dict_bit_diameter, $default_bit_diameter) / 2.0
			
			pt_arr = Array.new
			
			n_angles = 16
			delta = 360.0 / n_angles
			dr = Math::PI/180.0
			
			angle = 0.0
			for i in 0..n_angles
				radians = angle * dr
				pt_arr << Geom::Point3d.new(x + radius*Math.sin(radians), y + radius*Math.cos(radians), 0)
				angle += delta
			end

			status = view.draw_polyline(pt_arr)
		rescue
			UI.messagebox "Exception in PlungeTool.draw_geometry "+$!
		end
	end

	def create_geometry(view, x, y)
		model=view.model
		
		entities=model.entities
		model.start_operation "Creating Plunge Circle"
	
		radius = (Sketchup.active_model.get_attribute $dict_name, $dict_bit_diameter, $default_bit_diameter) / 2.0
		newedge = entities.add_line([@ip.position[0], @ip.position[1],0],[@ip.position[0]+radius, @ip.position[1],0])
		set_phlatboyz_edges([newedge], $key_plunge_cut, true, $color_plunge_cut)		

		vectz = Geom::Vector3d.new(0,0,1)###Z+
		circleInner = entities.add_circle(@ip.position, vectz, radius)
		entities.add_face(circleInner)

		model.commit_operation
	end


end
