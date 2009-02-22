require 'sketchup.rb'



def open_help_file	
	help_file = Sketchup.find_support_file "help.html", "Tools/Phlatboyz/"
	if (help_file)
		# Open the help_file in a web browser
		UI.openURL "file://" + help_file
	else
		UI.messagebox "Failed to open help file"
	end
end

def get_and_verify_directory(input_dir=nil)
	model = Sketchup.active_model
	if input_dir != nil
		dir_name = input_dir
	else
		dir_name = model.get_attribute $dict_name, $dict_output_directory_name, $default_directory_name
	end
	if not File.directory?(dir_name)
		dir_name = $default_directory_name
	end
	output_directory_name = ""
	arr = dir_name.split(/\//)
	arr.each {|element| output_directory_name << element << "/"} 

	model.set_attribute $dict_name, $dict_output_directory_name, output_directory_name
	#UI.messagebox(output_directory_name)
	return output_directory_name
end

def validate_output_file(output_file)
	result_array = nil
	begin
		file_basename = nil
		file_dirname = nil
		status = (output_file != nil)
		if(status)
			file_basename = File.basename(output_file)
			status = Sketchup.is_valid_filename?(file_basename)
			if(status)
				file_dirname = File.dirname(output_file)
				status = File.directory?(file_dirname)
			end
		end
		if(status)
			result_array = Array.new
			result_array[0] = file_dirname + File::SEPARATOR
			result_array[1] = file_basename
		else
			UI.messagebox($phlatboyzStrings.GetString("Filename Error") + ": " + ((output_file == nil) ? "nil" : output_file))
		end
	rescue
		UI.messagebox "Exception in validate_output_file "+$!
		nil
	end
	result_array  
end

def get_model_filename_or_default(model=Sketchup.active_model)
	begin
		path = model.path
		if path && path.length > 0
			path.match(/([a-zA-Z0-9\s]*)\.skp$/)
			default_filename = $1+".cnc"
		else
			#output_filename = model.get_attribute $dict_name, $dict_output_file_name, $default_file_name
			default_filename = $default_file_name
		end
	rescue
		UI.messagebox "Exception in PhlatboyzMethods.get_model_filename_or_default() "+$!
	end
	filename = model.get_attribute($dict_name, $dict_output_file_name, default_filename)
	#UI.messagebox("default_filename="+default_filename+" filename="+filename)
	return filename
end

def set_model_options(model)
	renderingoptions = model.rendering_options
	renderingoptions["EdgeColorMode"] = $rendering_edge_color_mode

	# Define "Hole" material
	m = model.materials.add "Hole"
	m.alpha = 0.5
	m.color = "white"

	#renderingoptions["EdgeDisplayMode"] = 1
end

def display_fold_depth_factor
	Sketchup::set_status_text "depth percent", SB_VCB_LABEL
	Sketchup::set_status_text $phlatboyzStrings.GetString("depth percent"), SB_VCB_LABEL
	fold_factor = get_fold_depth_factor()
	Sketchup::set_status_text fold_factor.to_s, SB_VCB_VALUE
end
def set_fold_depth_factor(in_factor, model=Sketchup.active_model)
	f = in_factor % 1000
	f = 110 if f > 110
	model.set_attribute $dict_name, $dict_fold_depth_factor, f
end
def get_fold_depth_factor(model=Sketchup.active_model)
	return model.get_attribute($dict_name, $dict_fold_depth_factor, $default_fold_depth_factor)
end
def set_tab_depth_factor(in_factor, model=Sketchup.active_model)
	model.set_attribute $dict_name, $dict_tab_depth_factor, in_factor % 80
end
def get_tab_depth_factor(model=Sketchup.active_model)
	return model.get_attribute($dict_name, $dict_tab_depth_factor, $default_tab_depth_factor)
end

def selected_edges(model=Sketchup.active_model)
	# Get selections from the active model
	# Get an Array of all of the selected Edges
	return model.selection.find_all { |e| e.kind_of?(Sketchup::Edge) }
end

def get_selected_edges(model=Sketchup.active_model)
	edges = selected_edges()
	# We need at least 1 Edge
	if( edges.length < 1 )
		UI.messagebox($phlatboyzStrings.GetString("You must select at least one Edge"))
		return nil
	else
		return edges
	end
end

def selected_faces(model=Sketchup.active_model)
	# Get selections from the active model
	# Get an Array of all of the selected Faces
	return model.selection.find_all { |e| e.kind_of?(Sketchup::Face) }
end


def get_selected_faces(model=Sketchup.active_model)
	faces = selected_faces
	# We need at least 1 Face
	if( faces.length < 1 )
		UI.messagebox($phlatboyzStrings.GetString("You must select at least one Face"))
		return nil
	else
		return faces
	end
end

def active_edges
	# Get all active edges
	entities = Sketchup.active_model.active_entities
	return entities.each { |entity| entity.kind_of?(Sketchup::Edge) }
end

def set_phlatboyz_edges(edges, key, store_edge_count=false, override_color=nil)
	if(key == $key_inside_cut)
		cut_depth_factor = $cut_depth_factor_inside
		material_color = $color_inside_cut
	elsif(key == $key_outside_cut)
		cut_depth_factor = $cut_depth_factor_outside
		material_color = $color_outside_cut
	elsif(key == $key_tab_cut)
		cut_depth_factor = get_tab_depth_factor()/100.0
		material_color = $color_tab_cut
	elsif(key == $key_fold_cut)
		cut_depth_factor = get_fold_depth_factor()/100.0
		material_color = $color_fold_cut
	end
	
	material_color = override_color if override_color
	edges.each do | edge |
		value = edge.set_attribute $dict_name, $dict_cut_depth_factor, cut_depth_factor
		edge.set_attribute $dict_name, $dict_edge_type, key

		if store_edge_count
			# TODO testing edge count algorithm for other edges 9/24/2008
			edge.set_attribute $dict_name, $dict_edge_count, $edge_count
			$edge_count += 1
		end

		edge.material = material_color
	end
end

def is_phlatboyz_edge(edge, and_match_type=nil)
	is_edge = false
	if(edge != nil)
		edgeType = edge.get_attribute $dict_name, $dict_edge_type
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

def set_edges_inside
	model = Sketchup.active_model
	#set_model_options(model)
	edges = get_selected_edges
	model.start_operation $phlatboyzStrings.GetString("operation_setting_inside_edges")
	set_phlatboyz_edges(edges, $key_inside_cut, true) # Use edge counting algorithm
	model.commit_operation
	model.selection.remove edges
end 

def set_edges_outside
	edges = get_selected_edges
	model = Sketchup.active_model
	model.start_operation $phlatboyzStrings.GetString("operation_setting_outside_edges")
	set_phlatboyz_edges(edges, $key_outside_cut, true) # Use edge counting algorithm
	model.commit_operation
	model.selection.remove edges
end 

def set_edges_fold
	edges = get_selected_edges
	
	if edges != nil
		if enter_set_fold_depth_dialog()
			model = Sketchup.active_model
			entities = model.entities
			
			model.start_operation $phlatboyzStrings.GetString("operation_setting_fold_edges")
			
			edges.each do | edge |
				ep1 = edge.start.position
				ep2 = edge.end.position

				newedges = Array.new
				if edge.length > $fold_shorten_width
					v = ep1.vector_to ep2 
					half = $fold_shorten_width/2
					point1 = ep1.offset(v, half)
					point2 = ep2.offset(v, -half)
					pointArray = Array[point1, point2]
					
					entities.erase_entities edge
					newedge = entities.add_line pointArray[0], pointArray[1]
					newedges << newedge
				end
				set_phlatboyz_edges(newedges, $key_fold_cut, true)
			end
			model.commit_operation
			model.selection.remove edges
		end
	end
end 

def set_edges_centerline
	edges = get_selected_edges
	
	if edges != nil
		if enter_set_fold_depth_dialog()
			model = Sketchup.active_model
			entities = model.entities
			
			model.start_operation $phlatboyzStrings.GetString("operation_setting_fold_edges")
			
			edges.each do | edge |
				ep1 = edge.start.position
				ep2 = edge.end.position
				newedges = Array.new
				newedge = entities.add_line ep1, ep2
				newedges << newedge
				set_phlatboyz_edges(newedges, $key_fold_cut, true, $color_centerline_cut)
			end
			model.commit_operation
			model.selection.remove edges
		end
	end

end



def clear_all_edges
	model = Sketchup.active_model
	model.start_operation $phlatboyzStrings.GetString("operation_clearing_all_edges")
	edges = active_edges
	edges.each do | edge |
		_clear_edge(edge)
	end
	model.commit_operation
end

def clear_selected_edges
	model = Sketchup.active_model
	model.start_operation $phlatboyzStrings.GetString("operation_clearing_selected_edges")
	edges = get_selected_edges
	edges.each do | edge |
		_clear_edge(edge)
	end
	model.commit_operation
	Sketchup.active_model.selection.remove edges
end

def set_z_zero_selected_edges(model=Sketchup.active_model)
	#model = Sketchup.active_model
	model.start_operation $phlatboyzStrings.GetString("operation_set_zequalzero_selected_edges")
	edges = get_selected_edges
	edges.each do | edge |
		_set_z_zero_edge(edge)
	end
	model.commit_operation
	Sketchup.active_model.selection.remove edges
end

def set_z_zero_selected_faces_and_edges(model=Sketchup.active_model)
	model.start_operation $phlatboyzStrings.GetString("operation_set_zequalzero_selected_edges_and_faces")
	
	faces = selected_faces()
	faces.each do | face |
		_set_z_zero_face(face)
	end
	
	edges = selected_edges()
	edges.each do | edge |
		_set_z_zero_edge(edge)
	end
	Sketchup.active_model.selection.remove edges
	model.commit_operation
end

def _set_z_zero_edge(in_edge, model=Sketchup.active_model)
	in_pt_start = in_edge.start.position
	in_pt_end = in_edge.end.position
	pt_start = Geom::Point3d.new(in_pt_start.x, in_pt_start.y, 0)
	pt_end = Geom::Point3d.new(in_pt_end.x, in_pt_end.y, 0)

	new_edges = model.entities.add_edges(pt_start, pt_end)
	new_edge = new_edges[0]

	model.entities.erase_entities in_edge
end

def set_z_zero_selected_faces(model=Sketchup.active_model)
	model.start_operation $phlatboyzStrings.GetString("operation_set_zequalzero_selected_faces")
	faces = get_selected_faces(model)
	faces.each do | face |
		_set_z_zero_face(face)
	end
	model.commit_operation
	Sketchup.active_model.selection.remove faces
end

def _set_z_zero_face(in_face, model=Sketchup.active_model)
	loop = in_face.outer_loop
	vertices = loop.vertices
	
	points = Array.new
	vertices.each do | vertex |
		points << Geom::Point3d.new(vertex.position.x, vertex.position.y, 0.0)
	end
	
	edges = loop.edges
	edges_to_remove = Array.new
	edges.each do | edge |
		edges_to_remove << edge if (edge.faces.length == 1)
	end
	model.entities.erase_entities edges_to_remove
	model.entities.add_face points
end





def _clear_edge(in_edge)
	in_edge.delete_attribute $dict_name, $dict_cut_depth_factor
	in_edge.delete_attribute $dict_name, $dict_edge_type
	in_edge.material = nil
end

# Erase all inside and outside edges
def erase_phlatboyz_edges
	model = Sketchup.active_model
	model.start_operation $phlatboyzStrings.GetString("operation_erasing_phlatboyz_edges")
	edges = active_edges
	edgeArray = Array.new
	edges.each do | edge |
		if is_phlatboyz_edge(edge, $key_inside_cut) || is_phlatboyz_edge(edge, $key_outside_cut) || is_phlatboyz_edge(edge, $key_tab_cut)
			edgeArray << edge
		end
	end
	while not edgeArray.empty? do
		edgeArray.pop.erase!
	end
	#UI.messagebox("last:"+edgeArray.size.to_s+" "+edgeArray.empty?.to_s)
	model.commit_operation
end

# ------------------------------------------------------------------------------------------------------------------------


def is_edge_in_safe_area(edge)
	vertices = edge.vertices
	#UI.messagebox(vertices[0].position.to_s)
	safe_point3d_array = get_safe_area_point3d_array()
	
	safe = Geom::point_in_polygon_2D vertices[0].position, safe_point3d_array, true
	if safe
		safe = Geom::point_in_polygon_2D vertices[1].position, safe_point3d_array, true
	end
	#UI.messagebox("edge="+edge.start.position.to_s+" "+edge.end.position.to_s+" safe="+safe.to_s)
	return safe
end





def set_safe_array(x, y, w, h, model=Sketchup.active_model)
	model.set_attribute $dict_name, $dict_safe_origin_x, x
	model.set_attribute $dict_name, $dict_safe_origin_y, y
	model.set_attribute $dict_name, $dict_safe_width, w
	model.set_attribute $dict_name, $dict_safe_height, h
end

def get_safe_array(model=Sketchup.active_model)
	x = model.get_attribute $dict_name, $dict_safe_origin_x, $default_safe_origin_x
	y = model.get_attribute $dict_name, $dict_safe_origin_y, $default_safe_origin_y
	w = model.get_attribute $dict_name, $dict_safe_width, $default_safe_width
	h = model.get_attribute $dict_name, $dict_safe_height, $default_safe_height
	return [x,y,w,h]
end

def _get_area_point3d_array(x, y, w, h)
	p0 = Geom::Point3d.new(x, y, 0)
	p1 = p0.transform Geom::Transformation.translation(Geom::Vector3d.new( w, 0, 0))
	p2 = p1.transform Geom::Transformation.translation(Geom::Vector3d.new( 0, h, 0))
	p3 = p2.transform Geom::Transformation.translation(Geom::Vector3d.new(-w, 0, 0))
	return [p0,p1,p2,p3]
end

def get_safe_origin_translation(model=Sketchup.active_model)
	x = model.get_attribute $dict_name, $dict_safe_origin_x, $default_safe_origin_x
	y = model.get_attribute $dict_name, $dict_safe_origin_y, $default_safe_origin_y
	return Geom::Transformation.translation(Geom::Vector3d.new(-x, -y, 0))
end

def get_safe_reflection_translation_old(model=Sketchup.active_model)
	y = model.get_attribute $dict_name, $dict_safe_origin_y, $default_safe_origin_y
	h = model.get_attribute $dict_name, $dict_safe_height, $default_safe_height
	origin = Geom::Point3d.new 0, (2*y + h), 0
	xp = Geom::Vector3d.new 1, 0, 0
	yp = Geom::Vector3d.new 0,-1, 0
	zp = Geom::Vector3d.new 0, 0,-1
	return Geom::Transformation.axes(origin, xp, yp, zp)
end

def get_safe_reflection_translation(model=Sketchup.active_model)
	x = model.get_attribute $dict_name, $dict_safe_origin_x, $default_safe_origin_x
	w = model.get_attribute $dict_name, $dict_safe_width, $default_safe_width
	origin = Geom::Point3d.new((2*x + w), 0, 0)
	xp = Geom::Vector3d.new(-1, 0, 0)
	yp = Geom::Vector3d.new( 0, 1, 0)
	zp = Geom::Vector3d.new( 0, 0,-1)
	return Geom::Transformation.axes(origin, xp, yp, zp)
end

def get_safe_area_point3d_array(model=Sketchup.active_model)
	safe_array = get_safe_array(model)
	x = safe_array[0]
	y = safe_array[1]
	w = safe_array[2]
	h = safe_array[3]
	return _get_area_point3d_array(x, y, w, h)
end

def mark_construction_object(in_object)
	in_object.set_attribute $dict_name, $dict_construction_mark, true
end

def erase_construction_objects(model=Sketchup.active_model)
	entities = model.active_entities
	entities_to_erase = Array.new
	entities.each do | entity |
		if(entity.get_attribute($dict_name, $dict_construction_mark))
			entities_to_erase << entity
		end
	end
	entities_to_erase.each { |entity| entities.erase_entities(entity)}
end

def add_point_label(in_entities, in_point, in_height, in_align)
	# align:0 - bottom, left
	# align:1 - top, right
	label = in_point.x.to_s+", "+in_point.y.to_s
	
	g = in_entities.add_group()
	g_entities = g.entities
	construction_point = g_entities.add_3d_text(label, TextAlignLeft, "Times", false, false, in_height, 0.1.inch, 0, true, 0)
	bbox = g.bounds
	
	v1 = (in_align == 0) ? Geom::Vector3d.new(-bbox.width/2, -1.5*bbox.height, 0) : Geom::Vector3d.new(-bbox.width/2, 0.5*bbox.height, 0)
	t = Geom::Transformation.new(in_point.offset(v1))
	
	g.move!(t)
	#g.explode()
	return g
end

def test_safe_area(safe_point3d_array, model=Sketchup.active_model)
	safe_area = (safe_point3d_array[0].distance safe_point3d_array[1]) > 0.5.inch
	safe_area &= (safe_point3d_array[1].distance safe_point3d_array[2]) > 0.5.inch
	return safe_area
end

def draw_safe_area(model=Sketchup.active_model)
	safe_point3d_array = get_safe_area_point3d_array(model)
	
	#UI.messagebox("draw_safe_area")
	erase_construction_objects(model)

	if(test_safe_area(safe_point3d_array, model))
		begin
			entities = model.active_entities
			
			mark_construction_object(entities.add_cline(safe_point3d_array[0], safe_point3d_array[1]))
			mark_construction_object(entities.add_cline(safe_point3d_array[1], safe_point3d_array[2]))
			mark_construction_object(entities.add_cline(safe_point3d_array[2], safe_point3d_array[3]))
			mark_construction_object(entities.add_cline(safe_point3d_array[3], safe_point3d_array[0]))

			mark_construction_object(entities.add_cpoint(safe_point3d_array[0]))
			mark_construction_object(entities.add_cpoint(safe_point3d_array[1]))
			mark_construction_object(entities.add_cpoint(safe_point3d_array[2]))
			mark_construction_object(entities.add_cpoint(safe_point3d_array[3]))

			#v1 = Geom::Vector3d.new(-0.125.inch, -0.125.inch, 0)
			#v2 = Geom::Vector3d.new(0.125.inch, 0.125.inch, 0)

			mark_construction_object(add_point_label(entities, safe_point3d_array[0], $construction_font_height, 0))
			mark_construction_object(add_point_label(entities, safe_point3d_array[2], $construction_font_height, 1))
		rescue
			UI.messagebox "Exception in draw_safe_area "+$!
			nil
		end
	end
end

def _test_order_edges
	edges = selected_edges()
	# We need at least 1 Edge
	if( edges.length < 2 )
		UI.messagebox($phlatboyzStrings.GetString("You must select at least two Edges"))
	else

		begin
			
#			start_verticies = edges.collect{|edge| edge.start}
#			end_verticies = edges.collect{|edge| edge.end}
#			all_verticies = start_verticies + end_verticies
			
			all_verticies = []
			edges.each{ |edge| all_verticies << edge.vertices }
			all_verticies.flatten!
			uniq_verticies = all_verticies.uniq
			
			non_dup_verts = uniq_verticies.reject {|v| ((i = all_verticies.index(v)) > -1) && ((j = all_verticies.rindex(v)) > -1) && (i != j)}
			# non_dup_verts will have two items when the curve is not closed, start vertex & end vertex; and it will be empty when the curve is closed

			#UI.messagebox("non_dup_verts.length="+non_dup_verts.length.to_s)
			#str = ""
			#non_dup_verts.each do |v|
			#	str += "  " + v.position.to_s
			#end
			#UI.messagebox(str)

			closed = (non_dup_verts.length == 0)
			start_vert = closed ? uniq_verticies.first : non_dup_verts.first
			start_edge = (start_vert.edges & edges).first

			UI.messagebox("start_edge="+start_edge.start.position.to_s+" -> "+start_edge.end.position.to_s)
			
			
			
			
			
		rescue
			UI.messagebox "Exception in _test_order_edges "+$!
		nil
	end

	
	
	
	
	end

end




def _test
	model = Sketchup.active_model

	modelMethods = Sketchup::ModelObserver.new.methods - Object.methods
	modelMethods.each{ |name| UI.messagebox(name)}
	
	
	#edges = get_selected_edges
	#model.start_operation "Test"
	#trans = get_safe_reflection_translation
	#edges.each do | edge |
	#	in_pt_start = edge.start.position.transform trans
	#	in_pt_end = edge.end.position.transform trans
	#	new_edges = model.entities.add_edges(in_pt_start, in_pt_end)
	#	new_edge = new_edges[0]
	#end
	#model.commit_operation
end
