
require 'sketchup.rb'
require 'Phlatboyz/Constants.rb'

class FoldTool
	@@nCursor = 0
	@@D = 1 # Depth Factor Index
	@@override_factor = 0
	@@wide_cut = false
	@@current_fold_color = @@wide_cut ? $color_fold_wide_cut : $color_fold_cut
	
	def initialize
		@ip = nil
		@saved_point_array = Array.new
		@@override_factor = get_fold_depth_factor()
		
		@valid_edge = false
		@edge_to_erase = nil
		
		if(@@nCursor == 0)
			cursorPath = Sketchup.find_support_file($cursor_fold_tool, $cursor_directory)
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
		self.compute_fold_depth_factor()
		display_fold_depth_factor()
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
		pointArray = foldPointsFromInputPoint(@ip)
		if(@valid_edge)
			@saved_point_array = pointArray
			view.tooltip = @ip.tooltip
		end
		view.invalidate if(@ip.display?)
	end
	
	def onLButtonDown(flags, x, y, view)
		@ip.pick view, x, y
		pointArray = foldPointsFromInputPoint(@ip)
		if(@valid_edge)
			@saved_point_array = pointArray
			self.create_geometry(view, @saved_point_array)
		end
		self.reset(view)
	    # Clear any inference lock
	    view.lock_inference
		#Sketchup::set_status_text "fold complete", SB_VCB_LABEL
	end
	
	def onKeyDown(key, repeat, flags, view)
		#Sketchup::set_status_text "key="+key.to_s, SB_VCB_LABEL
		refresh = false
		if(key > 47 && key < 58) # number keys
			@@override_factor *= 10
			@@override_factor += (key - 48)
			#@@override_factor %= 100
			refresh = true
		elsif key == 13 # enter key
			@@override_factor = 0
			refresh = true
		elsif key == 68 # D key
			@@D += 1
			@@override_factor = 0
			refresh = true
		elsif key == 87 # W key
			@@wide_cut = !@@wide_cut
			@@current_fold_color = @@wide_cut ? $color_fold_wide_cut : $color_fold_cut
			pointArray = foldPointsFromInputPoint(@ip)
			if(@valid_edge)
				@saved_point_array = pointArray
				view.tooltip = @ip.tooltip
			end
			refresh = true
		end
		if refresh
			self.compute_fold_depth_factor()
			display_fold_depth_factor()
			view.invalidate
		end
	end

	def draw(view)
		# Note: dont do anything in here that modifies the model
		if(@valid_edge)
			self.draw_geometry(view)
		end
	end
	
	def compute_fold_depth_factor
		if @@override_factor != 0
			fold_depth = @@override_factor
		else
			fold_depth = $fold_depth_factor_array[@@D % $fold_depth_factor_array.length]
		end
		set_fold_depth_factor(fold_depth)
	end
	
	def foldPointsFromInputPoint(inputPoint)
		pointArray = nil
		e = inputPoint.edge
		@valid_edge = false
		if(e != nil)
			edgeType = e.get_attribute $dict_name, $dict_edge_type
			if(edgeType == nil)
				@valid_edge = true
				if @@wide_cut
					@edge_to_erase = nil
					pointArray = Array[e.start.position, e.end.position]
				else
					@edge_to_erase = e
					
					ep1 = e.start.position
					ep2 = e.end.position

					if e.length > $fold_shorten_width
						v = ep1.vector_to ep2 
						half = $fold_shorten_width/2
						point1 = ep1.offset(v, half)
						point2 = ep2.offset(v, -half)
						pointArray = Array[point1, point2]
					end
				end
			end
		end
		return pointArray
	end

	# Draw the geometry
	def draw_geometry(view)
		view.drawing_color = @@current_fold_color
		view.line_width = 3.0
		#message = ""
		if(@saved_point_array.length > 0)
			point = @saved_point_array[0]
			1.upto(@saved_point_array.length - 1) do |p|
				view.draw_line(point, @saved_point_array[p])
				#message += " ("+point.x.to_s+","+point.y.to_s+")"
				point = @saved_point_array[p]
			end
		end
		#UI.messagebox(message)
	end

	def create_geometry(view, pointArray)
		model = view.model
		entities = model.entities
		if(@valid_edge)
			model.start_operation "Creating Fold"
			
			if @edge_to_erase != nil
				entities.erase_entities @edge_to_erase
				@edge_to_erase = nil
			end
			
			point = pointArray[0]
			1.upto(pointArray.length - 1) do |p|
				# TODO this could be add_edges which returns an array of edges ?? 10/29/2008
				newedge = entities.add_line point, pointArray[p]
				set_phlatboyz_edges([newedge], $key_fold_cut, true, @@current_fold_color)
				point = pointArray[p]
			end
			
			model.commit_operation
		    #Sketchup::set_status_text "Fold Created", SB_VCB_LABEL
		end
	end


end
