
require 'sketchup.rb'
require 'Phlatboyz/Constants.rb'

class CutTool
	@@inside_cursor = 0
	@@outside_cursor = 0
	@@inside_cut = true
	@offset_dist = 0.1.inch
	@switch_edge_side = false

	def initialize(inside_cut)
		@@N = 0
		@ip = nil
		@active_face = nil
		@@inside_cut = inside_cut

		if(@@inside_cursor == 0)
			cursorPath = Sketchup.find_support_file($cursor_inside_cuttool_filename, $cursor_directory)
			if cursorPath
				@@inside_cursor = UI.create_cursor(cursorPath, 13, 16)
			end	
		end

		if(@@outside_cursor == 0)
			cursorPath = Sketchup.find_support_file($cursor_outside_cuttool_filename, $cursor_directory)
			if cursorPath
				@@outside_cursor = UI.create_cursor(cursorPath, 13, 16)
			end	
		end
	end

	def onSetCursor()
		if(@@inside_cut)
			cursor = UI.set_cursor(@@inside_cursor)
		else
			cursor = UI.set_cursor(@@outside_cursor)
		end
	end

	def activate
	    @ip = Sketchup::InputPoint.new
	    Sketchup::set_status_text "CutTool Activated", SB_VCB_LABEL
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
		@active_face = activeFaceFromInputPoint(@ip)

		if(@active_face)
			view.tooltip = @ip.tooltip
			#Sketchup::set_status_text @ip.tooltip, SB_VCB_LABEL
		end
		view.invalidate if(@ip.display?)
	end

	def onLButtonDown(flags, x, y, view)
		@ip.pick view, x, y
		@active_face = activeFaceFromInputPoint(@ip)

		if(@active_face)
			self.create_geometry(@active_face, view)
		end
		self.reset(view)

		# Clear any inference lock
		view.lock_inference
		Sketchup::set_status_text "cut complete", SB_VCB_LABEL
	end

	def onKeyDown(key, repeat, flags, view)
		if key == CONSTRAIN_MODIFIER_KEY
			@switch_edge_side = true
			view.invalidate
		elsif key == 78
			@@N += 1
			@active_face = activeFaceFromInputPoint(@ip)
			view.invalidate
		end
	end

	def onKeyUp(key, repeat, flags, view)
		if key == CONSTRAIN_MODIFIER_KEY
			@switch_edge_side = false
			view.invalidate
		end
	end
	
	def draw(view)
		#&& @ip.valid? && @ip.display?
		if(@active_face)
			self.draw_geometry(view)
		end
	end

	def activeFaceFromInputPoint(in_inputPoint)
		#Sketchup::set_status_text "active N="+@N.to_s, SB_VCB_LABEL
		face = nil
		edge_from_input_point = in_inputPoint.edge
		face_from_input_point = in_inputPoint.face
		
		# check edge for non-phlatboyz edge
		if edge_from_input_point and not is_phlatboyz_edge(edge_from_input_point)
			#Sketchup::set_status_text "edge from input point", SB_VCB_LABEL
			faces = edge_from_input_point.faces
			if(faces)
				face = faces[@@N % faces.length]
				#Sketchup::set_status_text "gathered face N="+@N.to_s, SB_VCB_LABEL
				#UI.messagebox(@N)
			end
		elsif face_from_input_point
			#Sketchup::set_status_text "face from input point", SB_VCB_LABEL
			edges = face_from_input_point.edges
			edges_are_phlatboyz = false
			edges.each do | edge |
				if not edges_are_phlatboyz and is_phlatboyz_edge(edge)
					edges_are_phlatboyz = true
				end
			end
			if not edges_are_phlatboyz
				face = face_from_input_point
			end
		end
		if face
			bit_diameter = Sketchup.active_model.get_attribute $dict_name, $dict_bit_diameter, $default_bit_diameter
			if(@@inside_cut)
				@offset_dist = -bit_diameter/2
				@cut_key = $key_inside_cut
			else
				@offset_dist = bit_diameter/2
				@cut_key = $key_outside_cut
			end
		end
		return face
	end

	def create_geometry(face, view)
		model = view.model
		Sketchup::set_status_text "creating geometry", SB_VCB_LABEL
		old_edges = face.edges
		
		o = @offset_dist
		o = -@offset_dist if @switch_edge_side

		model.start_operation "Creating Cut"
		theface = face.offset(o)
		if(theface)
			delta_edges = theface.edges - old_edges
			theface.material = "Hole"
			set_phlatboyz_edges(delta_edges, @cut_key)
		else
			newedges = face.offsetEdges(o)
			if(newedges)
				set_phlatboyz_edges(newedges, @cut_key)
			end
		end
		
		model.commit_operation
	    Sketchup::set_status_text "Cut Created "+theface.to_s, SB_VCB_LABEL
		@switch_edge_side = false
	end

	# Draw the geometry
	def draw_geometry(view)
		view.drawing_color = $color_cut_drawing
		#view.line_stipple = "-"
		#view.line_width = 1.0
		#Sketchup::set_status_text "Drawing Offset", SB_VCB_LABEL
		if(@active_face != nil)
			o = @offset_dist
			o = -@offset_dist if @switch_edge_side
			new_point_array = @active_face.offsetPoints(o)
			
			#UI.messagebox(@active_face.outer_loop.outer?)
			view.draw GL_LINE_LOOP, new_point_array
		end
	end


end

