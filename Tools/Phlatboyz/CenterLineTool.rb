
require 'sketchup.rb'
require 'Phlatboyz/Constants.rb'

class CenterLineTool
	@@nCursor = 0
	@@D = 1 # Depth Factor Index
	@@override_factor = 0
	
	def initialize
		@ip = nil
		@saved_edge_array = Array.new
		@@override_factor = get_fold_depth_factor() #  TODO change to centerline depth factor ?
		
		@valid_edge = false
		
		if(@@nCursor == 0)
			cursorPath = Sketchup.find_support_file($cursor_centerline_tool, $cursor_directory)
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
		edgeArray = centerLineEdgesFromInputPoint(@ip)
		if(@valid_edge)
			@saved_edge_array = edgeArray
			view.tooltip = @ip.tooltip
		end
		view.invalidate if(@ip.display?)
	end
	
	def onLButtonDown(flags, x, y, view)
		@ip.pick view, x, y
		edgeArray = centerLineEdgesFromInputPoint(@ip)
		if(@valid_edge)
			@saved_edge_array = edgeArray
			self.create_geometry(view)
		end
		self.reset(view)
	    # Clear any inference lock
	    view.lock_inference
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

	
	#TODO move this? Also in FoldTool
	
	def compute_fold_depth_factor
		if @@override_factor != 0
			fold_depth = @@override_factor
		else
			fold_depth = $fold_depth_factor_array[@@D % $fold_depth_factor_array.length]
		end
		set_fold_depth_factor(fold_depth)
	end
	
	def centerLineEdgesFromInputPoint(inputPoint)
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
					UI.messagebox "Exception in CenterLineTool.centerLineEdgesFromInputPoint "+$!
				end
			end
		end
		return edgeArray
	end

	# Draw the geometry
	def draw_geometry(view)
		view.drawing_color = $color_centerline_cut
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
			UI.messagebox "Exception in CenterLineTool.draw_geometry "+$!
		end
	end

	def create_geometry(view)
		model = view.model
		entities = model.entities
		if(@valid_edge)
			model.start_operation "Creating Center Line"
			if not @saved_edge_array.empty?
				@saved_edge_array.each do | e |
					#newedge = entities.add_line(e.start.position, e.end.position)
					newedge = entities.add_line(e.start.position, e.end.position)
					set_phlatboyz_edges([newedge], $key_fold_cut, true, $color_centerline_cut)
				end
			end
			model.commit_operation
		end
	end


end
