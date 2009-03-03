# Copyright 2004,2005,2006 by Rick Wilson - All Rights Reserved
#
# 
# THIS SOFTWARE IS PROVIDED "AS IS" AND WITHOUT ANY EXPRESS OR
# IMPLIED WARRANTIES, INCLUDING, WITHOUT LIMITATION, THE IMPLIED
# WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE.
#
# Name :          offset.rb 2.1
# Description :   Offset edges of a selected face (new method for class Sketchup::Face)
# Author :        Rick Wilson
# Usage :         	1.	Intended for developers as a method to call from 
#				within a script.  Add a "require 'offset.rb' line
#				right after the "require 'sketchup.rb' line.  Distribute
#				with your script since not everyone will have this
#				already.  Returns the face created by the offset.
#			2.	Added method: ArcCurve.offset(dist) -- if dist is (+), offsets
#				outside the curve (larger radius); if dist is (-), offsets
#				inside the curve (smaller radius).
#			3.	Added method: Curve.offset(dist) -- if dist is (+), offsets
#				to the right of the curve (relative to the first segment direction
#				and plane); if dist is (-), offsets to the left of the curve.
# Date :          28 June 2006
# Type :          Methods
# History:
#			2.1 (28 June 2006) - 		changed the face creation to parent.entities.add_face to allow for correct creation regardless of nested status
#			2.0 (12 August 2005) - 	added offset methods for ArcCurve and Curve objects
#			1.0 (7 September 2004) - 	first version
# 

class Sketchup::Face

	def offset(dist)
		pts = self.offsetPoints(dist)
		#pts.push pts[0]
		
		# check point array for duplicates
		newPts=[]
		prevPt = nil
		0.upto(pts.length-1) do |p|
			#pts[p].z = 0.0
			if prevPt == nil || prevPt != pts[p]
				newPts.push pts[p]
			else
				#UI.messagebox("skipping point#"+p.to_s+" "+pts[p].to_s+"  prevPt="+prevPt.to_s)
			end
			prevPt = pts[p]
		end
		begin
			parent.entities.add_face(newPts)
		rescue
			UI.messagebox "Exception in PhlatOffset Face.offset() "+$!
			nil
		end
	end
	
	def offsetEdges(dist)
		pts = self.offsetPoints(dist)
		pts.push pts[0]
		parent.entities.add_edges(pts)
	end
	
	def offsetPoints(dist)
#		return nil if dist==0
		pi=Math::PI
		if (not ((dist.class==Fixnum || dist.class==Float || dist.class==Length) && dist!=0))
			return nil
		end
		verts=self.outer_loop.vertices
		pts=[]
		0.upto(verts.length-1) do |a|
			vec1=(verts[a].position-verts[a-(verts.length-1)].position).normalize
			vec2=(verts[a].position-verts[a-1].position).normalize
			vec3=(vec1+vec2).normalize
			if vec3.valid?
				ang=vec1.angle_between(vec2)/2
				ang=pi/2 if vec1.parallel?(vec2)
				vec3.length=dist/Math::sin(ang)
				t=Geom::Transformation.new(vec3)
				if pts.length > 0
					if not (vec2.parallel?(pts.last.vector_to(verts[a].position.transform(t))))
						t=Geom::Transformation.new(vec3.reverse)
					end
				end
				pts.push(verts[a].position.transform(t))
			end
		end
		pts
	end

end

class Array
	def offsetPoints(dist)
#		return nil if dist==0
		pi=Math::PI
		if (not ((dist.class==Fixnum || dist.class==Float || dist.class==Length) && dist!=0))
			return nil
		end
		verts=self
		pts=[]
		0.upto(verts.length-1) do |a|
			if verts[a-(verts.length-1)].class==Sketchup::Vertex
				pt2=verts[a-(verts.length-1)].position
			elsif verts[a-(verts.length-1)].class==Geom::Point3d
				pt2=verts[a-(verts.length-1)]
			else
				return nil
			end
			if verts[a-1].class==Sketchup::Vertex
				pt1=verts[a-1].position
			elsif verts[a-1].class==Geom::Point3d
				pt1=verts[a-1]
			else
				return nil
			end
			if verts[a].class==Sketchup::Vertex
				pt3=verts[a].position
			elsif verts[a].class==Geom::Point3d
				pt3=verts[a]
			else
				return nil
			end
			vec1=(pt3-pt2).normalize
			vec2=(pt3-pt1).normalize
			vec3=(vec1+vec2).normalize
			if vec3.valid?
				ang=vec1.angle_between(vec2)/2
				ang=pi/2 if vec1.parallel?(vec2)
				vec3.length=dist/Math::sin(ang)
				t=Geom::Transformation.new(vec3)
				if pts.length > 0
					if verts[a].class==Sketchup::Vertex
						pt = verts[a].position
					elsif verts[a].class==Geom::Point3d
						pt = verts[a]
					end
					if not (vec2.parallel?(pts.last.vector_to(pt.transform(t))))
						t=Geom::Transformation.new(vec3.reverse)
					end
				end
				if verts[a].class==Sketchup::Vertex
					pt = verts[a].position
				elsif verts[a].class==Geom::Point3d
					pt = verts[a]
				end
				pts.push(pt.transform(t))
			end
		end
		pts
	end
end

class Sketchup::ArcCurve
	def offset(dist)
		return nil if dist==0 || (not (dist.class==Float || dist.class==Fixnum || dist.class==Length))
		radius=self.radius+dist.to_f
		#Sketchup.active_model.active_entities.add_arc self.center, self.xaxis, self.normal, radius, self.start_angle, self.end_angle, self.count_edges
		c=parent.entities.add_arc self.center, self.xaxis, self.normal, radius, self.start_angle, self.end_angle, self.count_edges
		c.first.curve
	end
end

class Sketchup::Curve
	def offset(dist)
		return nil if self.count_edges<2
		pi=Math::PI
		if (not ((dist.class==Fixnum || dist.class==Float || dist.class==Length) && dist!=0))
			return nil
		end
		verts=self.vertices
		pts=[]
		0.upto(verts.length-1) do |a|
			if a==0 #special case for start vertex
				model=self.model
				model.start_operation "offset"
				gp=model.active_entities.add_group
				gpents=gp.entities
				face=gpents.add_face(verts[0].position,verts[1].position,verts[2].position)
				zaxis=face.normal
				v=self.edges[0].line[1]
				f=dist/dist.abs
				t=Geom::Transformation.rotation(verts[0].position,zaxis,(pi/2)*f)
				vec3=v.transform(t)
				vec3.length=dist.abs
				pts.push(verts[0].position.transform(vec3))
				gp.erase!
				model.commit_operation
			elsif a==(verts.length-1) #special case for end vertex
				model=self.model
				model.start_operation "offset"
				gp=model.active_entities.add_group
				gpents=gp.entities
				face=gpents.add_face(verts[a].position,verts[a-1].position,verts[a-2].position)
				zaxis=face.normal
				v=self.edges[a-1].line[1]
				f=dist/dist.abs
				t=Geom::Transformation.rotation(verts[a].position,zaxis,(pi/2)*f)
				vec3=v.transform(t)
				vec3.length=dist.abs
				pts.push(verts[a].position.transform(vec3))
				gp.erase!
				model.commit_operation
			else
				vec1=(verts[a].position-verts[a-(verts.length-1)].position).normalize
				vec2=(verts[a].position-verts[a-1].position).normalize
				vec3=(vec1+vec2).normalize
				if vec3.valid?
					ang=vec1.angle_between(vec2)/2
					ang=pi/2 if vec1.parallel?(vec2)
					vec3.length=dist/Math::sin(ang)
					t=Geom::Transformation.new(vec3)
					if pts.length > 0
						if not (vec2.parallel?(pts.last.vector_to(verts[a].position.transform(t))))
							t=Geom::Transformation.new(vec3.reverse)
						end
					end
					pts.push(verts[a].position.transform(t))
				end
			end
		end
		#Sketchup.active_model.active_entities.add_curve(pts)
		c=parent.entities.add_curve(pts)
		c.first.curve
	end
end

