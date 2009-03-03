
require 'sketchup.rb'
require 'Phlatboyz/Constants.rb'

class PlungeTool
	@@nCursor = 0
	@radius = 0.06.inch
	
	def initialize
		@ip = nil
		@radius = (Sketchup.active_model.get_attribute $dict_name, $dict_bit_diameter, $default_bit_diameter) / 2.0
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
		view.tooltip = @ip.tooltip if(@ip.edge != nil)
	end
	
	def onLButtonDown(flags, x, y, view)
		@ip.pick view, x, y
		self.create_geometry(view)
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

			n_angles = 16
			delta = 360.0 / n_angles
			dr = Math::PI/180.0
			angle = 0.0
			pt_arr = Array.new
			for i in 0..n_angles
				radians = angle * dr
				pt_arr << Geom::Point3d.new(x + @radius*Math.sin(radians), y + @radius*Math.cos(radians), 0)
				angle += delta
			end

			status = view.draw_polyline(pt_arr)
		rescue
			UI.messagebox "Exception in PlungeTool.draw_geometry "+$!
		end
	end

	def create_geometry(view)
		model = view.model
		model.start_operation "Creating Plunge Circle"
		
		entities = model.entities
	
		center = Geom::Point3d.new(@ip.position.x, @ip.position.y, 0)
		end_pt = Geom::Point3d.new(@ip.position.x + @radius, @ip.position.y, 0)
		newedge = entities.add_line(center, end_pt)
		
		set_phlatboyz_edges([newedge], $key_plunge_cut, true, $color_plunge_cut)		

		vectz = Geom::Vector3d.new(0,0,1)###Z+
		circleInner = entities.add_circle(center, vectz, @radius)
		entities.add_face(circleInner)

		
		
		model.commit_operation
	end


end
