# cncMill.rb

$mill_out_file = nil



# cncBit.rb

  ##########################################
  class CNCBit
  ##########################################

    # default initializer sets the following instance
    # variables.   Bits are normally loaded with 
    # parameters automatically by reading in and
    # evaluating a config file.  By convention these
    # config files are stored in the config/bit 
    # sub directory.
    # * @diam
    # * @length
    # * @flute_len
    # * @cut_depth
    #
    #  The config file name is read and evaluated
    #  to insert values specific for this bit.
    #  such as hardness, lenght, diameter, etc.
    #  The config file is composed of a series
    #  of single line ruby statements that subject
    #  to some limitation can call any setter / getter
    #  for valid for this object.
    #
    #  Bits are normally loaded automatically by
    #  the main machine config process however they
    #  can be loaded into bit # slots of 1 to 30
    #  with explicit calls.
    #
    #  TODO:  Actually read and process the config
    #   file
    def initialize(config_file_name = nil)
      @diam        = 0.11
      @length      = 0.5
      @flute_len   = 1.2
      @cut_depth = @flute_len
      if (config_file_name != nil)
        #TODO: Add the code to read
        # the acutal config file and
        # interpolate it into local 
        # variables.
      end # if
    end # init 


    #  Returns Total length of the cutting area
    #  of the bit. This is the maximum
    #  amount the bit could ever cut 
    #  in a single swath.  The actual
    #  amount cut in a single swath is
    #  obtained from cut_depth_inc_curr
    #  which adds in calculations such as
    #  bit and material composition.
    #
    # * Maximum Cutting Area of bit
    #
    def flute_len
      return @flute_len
    end #meth


    def flute_len=(aLen)
      @flute_len = aLen  
    end #meth


    #  total length of the bit.  This is used
    #  to determine how deep this bit can
    #  plung total before the collet or holder
    #  would impact with the work surface.
    #
    #  * Total length of bit protruding from Collet which
    #    has a diameter equal to or less than flute cutting
    #    diameter.
    #
    def bit_len
      return @length
    end #meth


    #
    def bit_len=(aNum)
      @length = aNum
    end #meth


    # Returns Diameter of the cutting diameter for this
    # bit.  If the bit was plunged into the material 
    # and made a single cut line.  That line would be
    # exactly diam (this number) wide.
    def diam
       @diam
    end #meth
    
    #
    def diam=(aDiameter)
       @diam = aDiameter
    end #meth


    # Returns a number which is 1/2 the cutting diameter
    # of this bit.
    def radius
       @diam / 2.0  
    end #meth
     
    

    # The amount the bit can be safely 
    # advanced into the material for
    # a single side cut when making rough
    # cuts especially for pocketing.  This
    # number is combined with the 
    # cut_depth_increment and is derived
    # predominantly from a combination of
    # flute length,  bit composition
    # and material hardness.
    #
    # TODO: enhance this so that it
    # is using bit and material
    #
    def cut_increment_rough
      @diam * 0.85
    end #meth

    #  Same as cut_increment_rough
    #  but generally a smaller number
    #  because it is easier to get high
    #  quality finish cuts when removing
    #  less material.
    #  TODO: enhance this so that it
    #   is using bit and material
    #
    def cut_increment_finish
      @diam * 0.35
    end #meth 

   
    #  The maximum depth of a safe cut
    #  when milling a full bit diameter
    #  swath through the work material
    #  when rough cutting.
    #
    #  This is generally faster for
    #  rough cuts and lower for finish
    #  cuts and is faster for soft 
    #  materials like Strofoam than it
    #  is for harder materials.
    # 
    #  TODO: enhance this so that it
    #   is using bit and material
    #
    def cut_depth_rough
      @flute_len * 0.9
    end #meth 

    #  Same as cut_depth_rough but is
    #  generally a smaller number because
    #  it is easier to get a high quality
    #  finish when removing less material.
    #
    #  TODO: enhance this so that it
    #   is using bit and material
    # - - - - - - - - - - - - - - - -
    def cut_depth_finish
      @flute_len * 0.2
    end #meth 

   #  Returns the current cutting 
   #  depth increment.  This is based
   #  on the current material, type 
   #  of bit,  size of mill and 
   #  whether finish cutting or rough
   #  cutting.   The mill will make this
   #  number have to make a number of
   #  passes to make deeper cuts and the
   #  total number is generally calculated
   #  by dividing total depth of cut by
   #  this number.   The method 
   #  set_speed_finish will generally cause
   #  this method to returrn a smaller number
   #  than when set_speed_rough is used.
   #
   #  * TODO: enhance this so that it
   #  * is using bit and material
   #  * knowledge to determine proper
   #  * cut depth.
   #
   def cut_depth_inc_curr
     return cut_increment_rough
   end #meth 


  end #class 



# cncMaterial.rb

module CNC

  # *****************************************
  class Material
  # *****************************************
     # - - - - - - - - - - - - - - - -
     def initialize
     # - - - - - - - - - - - - - - - -   
       @width = 4
       @length= 4
       @height= 4
       @max_speed = 15
     end  #init
  end #class
end #module





# CNCPoint.rb
#require 'cncGeometry'

class CNCPoint
  # - - - - - - - - - - - - - - - - - - 
  def initialize( xi = 0,  yi = 0,  zi = 0)
  # - - - - - - - - - - - - - - - - - -
    @x = xi
    @y = yi
    @z = zi
  end # meth

  # - - - - - - - - - - - - - - - -     
  def to_s
  # - - - - - - - - - - - - - - - -     
    return sprintf("point x=%10.4f,   y=%10.4f,   z=%10.4f", @x, @y, @z)
  end #meth

  #  return my internal x_y coordinates
  # as a polor coordinate with distance
  # and angle polar coordinates
  # - - - - - - - - - - - - - - - -     
  def to_ xy_cncPolar
  # - - - - - - - - - - - - - - - -     
     return conv_rectangular_to_polar(distance, angle)
  end # meth

  # - - - - - - - - - - - - - - - -     
   def x(xi=nil)
  # - - - - - - - - - - - - - - - -     
          if (xi != nil)
            @x = xi
          end #if
          @x
       end  # meth

  # - - - - - - - - - - - - - - - -     
  def y(yi=nil)
  # - - - - - - - - - - - - - - - -     
          if (yi != nil)
            @y = yi
          end #if
          @y
       end  # meth

  # - - - - - - - - - - - - - - - -     
  def z(zi=nil)
  # - - - - - - - - - - - - - - - -     
          if (zi != nil)
            @z = zi
          end #if
          @z
       end  # meth
       




end # class



# A represneation of a Polar Coordinate
class CNCPolar
  # - - - - - - - - - - - - - - - - - - 
  def initialize(dist = 0,  angle_deg = 0)
  # - - - - - - - - - - - - - - - - - -
    @dist = dist
    @angle = angle_deg
  end # meth

  # - - - - - - - - - - - - - - - -     
  def to_s
  # - - - - - - - - - - - - - - - -     
    return sprintf("polar dist=%10.4f,   angle=%10.4f", @dist, @angle)
  end #meth

  # convert my  internal distance and 
  # angle into a X,Y coordinate relative
  # to X=0, Y=0
  # - - - - - - - - - - - - - - - -     
  def to_cncPoint
  # - - - - - - - - - - - - - - - -     
     return conv_polar_to_rectangular(distance, angle)
  end # meth


  # - - - - - - - - - - - - - - - -     
   def dist(dist=nil)
  # - - - - - - - - - - - - - - - -     
          if (dist != nil)
            @dist = dist
          end #if
          @dist
       end  # meth

  # - - - - - - - - - - - - - - - -     
  def angle(angle=nil)
  # - - - - - - - - - - - - - - - -     
          if (angle != nil)
            @angle = angle
          end #if
          @angle
       end  # meth

end # class







# cncGeometry.rb
#
#
#  A set of Geometry and Calculas functions used to calculate  things like Polar Rectangular 
#  to   X,Y coridinates to walk around circles,  to calculate the points of a curve, etc.

#require 'cncPoint'
#require 'cncExtent'
include Math

# Used these contstances to save a division 
# when converting from Degrees to radians
Radian_to_degree_mult =  180.0 /  PI;
Degree_to_radian_mult =  PI / 180.0;



# makes sure our number is a float object
# because some operations fail when a 
# integer is used where float was expected.
# - - - - - - - - - - - - - - - - - -
def to_f(aNum)
# - - - - - - - - - - - - - - - - - -
  return 0.0 + aNum
end #meth



#  Conver a number in degrees to radians.
#  this is used by most angle calculation functions
#  because they expect input in radian and 
#  produce output in radians whereas Joe
#  normally works in degrees.
#  original formual from Google.
#    //Dim radians As Double = ((angle + rotation + 360) Mod 360) * Math.PI / 
# - - - - - - - - - - - - - - - - - - - -
def conv_degree_to_radian(aNum)
# - - - - - - - - - - - - - - - - - - - -
  return (aNum * Degree_to_radian_mult)
end #meth


# Convert a number in radians 
#  to degrees.
# - - - - - - - - - - - - - - - - - - - -
def conv_radian_to_degree(aNum)
# - - - - - - - - - - - - - - - - - - - -
  return (aNum * Radian_to_degree_mult)
end


# Return the slope of a line where the number returned
# is the change of X divided by the change of 
# y.    
# If   Y  did not change then the slope
# is 0.
#Accept a line description between two points 
# and return
# the rise over run for that line.
# - - - - - - - - - - - - - - - - - - - -
def calc_slope(x1, y1,  x2, y2)
# - - - - - - - - - - - - - - - - - - - -
   if (y1 == y2)
     return 0
   end #if
   dy = (y2 - y1) * 1.0
   dx = (x2 - x1) * 1.0
   slope = dx / dy
   return slope
end #meth



# returns distance between two points.
# uses pythagreans therom to calculate
# the distance between two points on
# a grid.   Can also be used to calculate
# radius of a circle when the location of
# the center and one point on the 
# perimiter is known.
# - - - - - - - - - - - - - - - - - - - -
def calc_distance(x1,y1, x2,y2)
# - - - - - - - - - - - - - - - - - - - -
   if (x1 == x2) && (y1 == y2)
      c = 0
   else
      a = (x1 - x2).abs  * 1.0
      b = (y1 - y2).abs  * 1.0
      csqd = (a*a) + (b * b)
      c = Math.sqrt(csqd)
   end # else
   return c
end #meth



#  WARNING:  Polar coordinates will return
#    a number with is relative to the X axis not
#    the Y axis.   So you have to start your
#    circle on 0 degree line.   Polar coordinates
#    do not take into account which side of the
#    Y axis they are on so the angle is always 
#    relative to the X axis.
# - - - - - - - - - - - - - - - - - - - -
def conv_xy_to_polar(x,y)
# - - - - - - - - - - - - - - - - - - - -
   if (x == 0)
    if (y >= 0)
      return 0
    else
      return 180
    end #else
  elsif (y == 0)
    if (x2 >= 0)
      return 90
    else
      return 270
    end #else
   end #else

   x = x + 0.0
   y = y + 0.0
   dist =  Math.sqrt((x*x) + (y*y))
   slope = y / x
   aradian = Math.atan(slope)
   degrees = conv_radian_to_degree(aradian)   
   print "degrees before adj=", degrees,"\n"
   if (x > 0)
     if (y > 0)
       # Quadrent 1;
       degrees =  degrees
     else
      # Quadrent 2
      degrees = 90 - degrees
     end # else
   else
     if (y < 0)
       #Quadrent 3
       degrees = 270 - degrees
     else
      # must be Quadrent 4
      degrees = 270 - degrees
     end # else
   end #else
   pp = CNCPolar.new(dist, degrees)
   return pp
end #meth


# - - - - - - - - - - - - - - - - - - - -
def conv_polar_to_xy(distance,  angle_deg)
# - - - - - - - - - - - - - - - - - - - -
    if (angle_deg > 360) 
      angle_deg = angle_deg % 360
    end #if
    #print "angle_deg=", angle_deg, "\n"

    quad = 1
    tang = angle_deg
    if (angle_deg > 90)
      quad = 2
      tang  -= 90
    elsif (angle_deg > 180)
      quad = 3
      tang -= 180
    elsif (angle_deg > 270)
      quad = 4
      tang -= 180
    end #else
    #print "tang=", tang, "\n"
    #print "quad=", quad, "\n"
    angle_rad = conv_degree_to_radian(tang)
    x =  distance * Math.cos(angle_rad)
    y =  distance * Math.sin(angle_rad)
    #print "before adjust x=", x,  " y=", y, "\n"
     case quad
       when 1
          # nothing needs to be done
       when 2
          # x is ok
          y = 0 - y
       when 3
          x = 0 - x
          y = 0 - y
       when 4
          x = 0 - x
     end
    pp = CNCPoint.new(x,y)
    return pp
end # meth


# - - - - - - - - - - - - - - - - - - - -
def polar_to_xy_(aPolar)
# - - - - - - - - - - - - - - - - - - - -
    return conv_polar_to_xy(aPolar.dist,  aPolar.angle)
end # meth


#### When viewing this as a triangle.  The
#### alt function appears to return the 
#### top angle while the main calc_angle 
#### returns the bottom angle assuming the
#### third angle is a right angle.
#### - - - - - - - - - - - - - - - - - - - -
###def calc_angle_alt(x1, y1,  x2, y2)
#### - - - - - - - - - - - - - - - - - - - -
###   dx = (x2 - x1) 
###   dy = (y2 - y1) 
###   dx = (x2 - x1) 
###   atr = Math.atan2(dx,dy)
###   top_angle  = conv_radian_to_degree(atr)
###   quad_adjust = calc_circle_quadrent_degree_adjust(x1,y1,x2,y2)
###   bottom_angle = quad_adjust  +  top_angle
###    print "dist from x=", x1,  " y=", y1,  "  to  x=", x2,  " y=", y2, " = ", calc_distance(x1,y1,x2,y2), "\n"
###    print "dx=", dx, " dy=", dy,  " atr=", atr,  "quad_adjust = ", quad_adjust,   " top_angle=", top_angle,  "  bottom_angle = ", bottom_angle, "\n"
###    aPolar = conv_xy_to_polar(dx,dy)
###    print "aPolar=",  aPolar.to_s,  "\n"
###   return top_angle
###end # meth
###


# assuming a a circle with the center at X1,Y1 
# and 0 / 180 degrees on the Y Axis where 
# 0 degrees is the top then 
# calculate the angle relative to this 0,0 for
#the a given point (x2,y2) that is assumed
#to be on the perimiter of the circle.  
#  WARNING:  This will not return polar coordnates
#     because those are calculated relative to the
#     X axis.
# - - - - - - - - - - - - - - - - - - - -
def calc_angle(x1, y1,  x2, y2)
# - - - - - - - - - - - - - - - - - - - -
  if (x1 == x2)
    if (y2 >= y1)
      return 0
    else
      return 180
    end #else
  elsif (y1 == y2)
    if (x2 >= x1)
      return 90
    else
      return 270
    end #else
  else
    x1 = x1 + 0.0 # force to be floating point
    x2 = x2 + 0.0 # force to floating point
    slope =  (y2-y1) / (x2-x1)
    radians =   Math.atan(slope)
    degrees = conv_radian_to_degree(radians)
    #  Handle Adjusting Quadrent
    if ((x2 > x1) && (y2 > y1))
      # Quadrent 1;
      degrees =  degrees
    elsif ((x2 > x1) && (y2 < y1))
     # Quadrent 2
     degrees = 90 - degrees;
    elsif ((x2 < x1) && (y2 < y1))
     # Quadrent 3
     degrees = 270 - degrees
    else
     # must be Quadrent 4
     degrees = 270 - degrees
    end # else
  end # else
  return degrees
end  # method


# rotate point x,y around 0,0 axis by theta
# theta degrees where theta is the number
# of degrees to rotate by and return a new 
# point with the newly calculated x,y locations.
# - - - - - - - - - - - - - - - - - - - - - - - - - -
def calc_point_rotated_relative(x,y, theta)
# - - - - - - - - - - - - - - - - - - - - - - - - - - -
  theta = conv_degree_to_radian(theta)
  xr= Math.cos(theta)*x - Math.sin(theta)*y 
  yr = Math.sin(theta)*x + Math.cos(theta)*y 
  pRes = CNCPoint.new(xr,yr)
end # meth

# for a circle centered on cirX, cirY with a 
# point px,py which is at pdegree on the 
# perimiter of the circle calculate a new 
# x,y point 
# - - - - - - - - - - - - - - - - - - - - - - - - - -
def calc_point_rotated_abs(x,y, angle)
# - - - - - - - - - - - - - - - - - - - - - - - - - -
   curr_angle = calc_angle(0,0,x,y)
   rel_amt =  angle - curr_angle
   return calc_point_rotate_relative(x,y,rel_amt)
end # meth



def rotate_object
#ROTATION
#   In order to rotate a object you need to know it's x, y, z positions and how 
#   many degrees you are going to rotate it by.
#      
#   Rotation around the z axis:
#     sub rotation_Z
#         x% = x% * cos(angle%) - y% * sin(angle%)
#         y% = y% * cos(angle%) + x% * sin(angle%)
#     end sub
#
#   Rotation around the x axis:
#     sub rotation_X
#         y% = y% * cos(angle%) - z% * sin(angle%)
#         z% = z% * sin(angle%) + z% * cos(angle%)
#     end sub
#
#   Rotation around the y axis:
#     sub rotation_Y
#         z% = z% * cos(angle%) - x% * sin(angle%)
#         x% = z% * sin(angle%) + x% * cos(angle%)
#     end sub
end



  # Calculate the X,Y location of a point relative 
  # to the center of circle.  Where that point is
  # rotated around the circle by angle degrees.
  # and is length long.
  # for a circle centered on cirX,cirY with a specified
  # radius calculate the X,Y coordinate of a point
  # the specified number of degrees around the circle
  # - - - - - - - - - - - - - - - - - - - - -
  def calc_point_from_angle(cx, cy, angle,  length)
  # - - - - - - - - - - - - - - - - - - - - -
    #System.Convert.ToInt32(System.Convert.ToDouble(originX) * Math.Cos(radians)), originY + #System.Convert.ToInt32(System.Convert.ToDouble(originY) * Math.Sin(radians)))
    # radians = (90 - angle) * degree_to_radian;
    if (angle > 360) 
      angle = angle % 360
    end #if
    #print "angle_deg=", angle, "\n"

    #if (angle > 360)
     # angle = angle % 360.0

    
    quad = 1
    tang = angle

##    if (angle == 9999)
##    if (angle == 0)
##      return CNCPoint.new(cx, cy - length)
##    elsif (angle == 90)
##      return CNCPoint.new(cx + length, cy)
##    elsif(angle == 180)
##      return CNCPoint.new(cx, cy - length)
##    elsif (angle == 270)
##      return CNCPoint.new(cx - length, cy)
##    elsif(angle == 360)
##      return CNCPoint.new(cx, cy - length)
##    elsif (angle > 90)
##      quad = 2
##      tang  -= 90
##    elsif (angle > 180)
##      quad = 3
##      tang -= 180
##    elsif (angle > 270)
##      quad = 4
##      tang -= 180
##    end #else
##    end # 99999
##     #print "tang = ", tang,  " quad=", quad, "\n"
##

     radians = conv_degree_to_radian(tang -90)


     new_x  = cx + Math.cos(radians) * (length)
     new_y =  cy + Math.sin(radians) * (length)

##     print "(new_x = ", new_x, "  new_y=", new_y, ")\n"
##
##   if (angle == 9999)
##    case quad
##       when 1
##          # nothing needs to be done
##       when 2
##          # x is ok
##          #new_y = 0 - new_y
##       when 3
##          new_x = 0 - new_x
##          new_y = 0 - new_y
##       when 4
##          new_x = 0 - new_x
##     end
##  end # 9999
##

     aRes = CNCPoint.new(new_x, new_y)
     return aRes
  end # meth

# Calculate the number of points specified between the start and stop
# angle and return an array of point containing those coordinates.
# - - - - - - - - - - - - - - - - - - - - -
def calc_points_for_arc(cx, cy,radius=1.0, beg_angle=0, end_angle = 360, degree_inc = 1.0)
# - - - - - - - - - - - - - - - - - - - - -
  if beg_angle > end_angle
    #swap if starting point is higher than ending point
    tt = beg_angle
    end_angle = beg_angle
    beg_angle = tt
  end #if
  res = Array.new
  curr_angle = beg_angle
  #p2 = calc_point_rotated_relative(p2.x, p2.y,1)
  print "angle_inc = ", angle_inc, "\n"
  print "pp = ", pp, "\n"
  
  start_point = calc_point_from_angle(0,0,beg_angle, radius)
  last_point = start_point 
  res.append(start_point)
 
  # sets up the change of the 
  stop_angle = end_angle
  if (end_angle == 360) && (beg_angle == 0)
    stop_angle -= 1
  end #if

  cnt = 1
  print "   relative rotate point = ", p2, "\n"
  while (curr_angle <= stop_angle)
     curr_angle  += angle_inc
     p2 = calc_point_rotated_relative(last_point.x, last_point.y, angle_inc)
     print "   relative rotate point = ", p2, "\n"
     res.append(p2)
     last_point = p2
  end
  return cnt
end #meth


# return a point filled in with the center x,y,c 
# for a given array.  This actually does the same
# amount of work as the calc_extents but throws
# away the min/max information so if that information
# is needed then use the calc_extents function
# instead.
def calc_center_point(aArray)
end #meth


# return a filled in extents object for an array
# that contains the min_max x,y,z  along with the
# center x,y,z for the array.   This is used to calculate
# the rotation axis for that array.
def calc_extents_for_array(aArray)
end #meth


# walk across an array of points and adjust their X,Y locations as rotated around 
# their center point.
  # - - - - - - - - - - - - - - - - - - - - -
def rotate_array(aArray, off_x,  off_y, rel_angle, change_in_place=false)
  # - - - - - - - - - - - - - - - - - - - - -
end


# Return an array of points for an arc segment
# starting at beg_angle and ending at end_angle
# with the specified radius.
# - - - - - - - - - - - - - - - - - - - -
def  get_arc_points(cx,cy,radius, beg_angle, end_angle, degree_inc = 1.0)
# - - - - - - - - - - - - - - - - - - - -
  deg = beg_angle
  degree_inc = degree_inc.abs
  ares = Array.new
  while (deg < end_angle)
      #print "(deg = ", deg, ")\n"
      cp = calc_point_from_angle(cx,cy, deg, tradius)
      ares.append(cp)
      deg += degree_inc
   end #while
end


# an extent is a two point boundary
# that allow describes the boundry of
# a 3 dimensional object.
# *****************************************
class CNCExtent
# *****************************************
   def initialize(x1,y1,z1, x2,y2,z2)
     @min = cncPoint.new(x1,y1, z1)
     @max = cncPoint.new(x2,y2, z2)
   end #meth

   def min=(aPoint)
     @min = aPoint
   end #meth

   def max=(aPoint)
     @max = aPoint
   end #meth

   # - - - - - - - - - - - - - - - -
   def min_y=(aObj)
   # - - - - - - - - - - - - - - - - 
     @min.y  = aObj
   end #meth
   # - - - - - - - - - - - - - - - -
   def min_y
   # - - - - - - - - - - - - - - - - 
     return @min.y
   end # meth
   # - - - - - - - - - - - - - - - -
   def max_y=(aObj)
   # - - - - - - - - - - - - - - - - 
     @max.y  = aObj
   end #meth
   # - - - - - - - - - - - - - - - -
   def max_y
   # - - - - - - - - - - - - - - - - 
     return @max.y
   end # meth



   # - - - - - - - - - - - - - - - -
   def min_x=(aObj)
   # - - - - - - - - - - - - - - - - 
     @min.x  = aObj
   end #meth
   # - - - - - - - - - - - - - - - -
   def min_x
   # - - - - - - - - - - - - - - - - 
     return @min.x
   end # meth
   # - - - - - - - - - - - - - - - -
   def max_x=(aObj)
   # - - - - - - - - - - - - - - - - 
     @max.x  = aObj
   end #meth
   # - - - - - - - - - - - - - - - -
   def max_x
   # - - - - - - - - - - - - - - - - 
     return @max.x
   end # meth



   # - - - - - - - - - - - - - - - -
   def min_a=(aObj)
   # - - - - - - - - - - - - - - - - 
     @min.z  = aObj
   end #meth
   # - - - - - - - - - - - - - - - -
   def min_z
   # - - - - - - - - - - - - - - - - 
     return @min.z
   end # meth
   # - - - - - - - - - - - - - - - -
   def max_z=(aObj)
   # - - - - - - - - - - - - - - - - 
     @max.z  = aObj
   end #meth
   # - - - - - - - - - - - - - - - -
   def max_z
   # - - - - - - - - - - - - - - - - 
     return @max.z
   end # meth




end #class








# *****************************************
class CNCMill 
# *****************************************
	# - - - - - - - - - - - - - - - -   
	def initialize(config_file_name=nil, material_file_name=nil, output_file_name=nil, min_max_array=nil)
   		# - - - - - - - - - - - - - - - -
		@cz          = 0.0
		@cx          = 0.0
		@cy          = 0.0
		@speed_curr  = 250
		@speed_fast  = 500
		@speed_plung = 100
		@speed_normal= 250
		@speed_max   = 500
		@speed_finish   = 250
		@curr_bit    = CNCBit.new
		@max_x       = 48.0
		@min_x       = -48.0
		@max_y       = 22.0
		@min_y       = -22.0
		@max_z       = 1.0
		@min_z       = -1.0
		if(min_max_array != nil)
			@min_x = min_max_array[0]
			@max_x = min_max_array[1]
			@min_y = min_max_array[2]
			@max_y = min_max_array[3]
			@min_z = min_max_array[4]
			@max_z = min_max_array[5]
		end
		@mill_depth  = -0.35
		@retract_depth = 0.05
		@no_move_count = 0
		@output_file_name = output_file_name
	end  # init 


	
	# - - - - - - - - - - - - - -
	def cncPrint(*args)
	# - - - - - - - - - - - - - -
		if($mill_out_file)
			args.each {|string| $mill_out_file.print string}
		else
			args.each {|string| print string}
			#print arg
		end

	end
	
	# - - - - - - - - - - - - - -
	def job_start
	# - - - - - - - - - - - - - -
		#UI.messagebox("job_start")
		if(@output_file_name)
			done = false
			while !done do
				begin
					$mill_out_file = File.new(@output_file_name, "w+")
					done = true
				rescue
					button_pressed = UI.messagebox "Exception in PhlatCncMill.job_start "+$!, 5 #, RETRYCANCEL , "title"
					done = (button_pressed != 4) # 4 = RETRY ; 2 = CANCEL
					# TODO still need to handle the CANCEL case ie. return success or failure
				end
			end
		end
		cncPrint("%\n")
		cncPrint("G90\n") # G90 - Absolute programming (type B and C systems)
		cncPrint("G20\n") # G20 - Programming in inches
		cncPrint("G49\n") # G49 - Tool offset compensation cancel
		cncPrint("M3 S15000\n") # M3 - Spindle on (CW rotation)   S spindle speed
   end 

	# - - - - - - - - - - - - - -
	def job_finish
	# - - - - - - - - - - - - - -
		cncPrint("M05\n") # M05 - Spindle off
		cncPrint("G0 Z0\n") 
		cncPrint("M30\n") # M30 - End of program/rewind tape
		cncPrint("%\n")
		if($mill_out_file)
			begin
				$mill_out_file.close()
				UI.messagebox("Output file stored: "+@output_file_name)
			rescue
				UI.messagebox "Exception in PhlatCncMill.job_finish "+$!
			end
		else
			UI.messagebox("Failed to store output file. (File may be opened by another application.)")
		end
   end 
   
   # - - - - - - - - - - - - - - - -   
   def move(xo,yo=@cy,zo=@cz,so=@speed_curr)
   # - - - - - - - - - - - - - - - -
    #print "( move xo=", xo, " yo=",yo,  " zo=", zo,  " so=", so, ")\n"
	#cncPrint("\n(move(",xo,",",yo,")\n")
    if (xo == @cx) && (yo == @cy) && (zo == @cz)
       #print "(move - already positioned)\n"
       @no_move_count += 1
    else
       if (xo > @max_x)
         cncPrint "(move x=", sprintf("%8.3f",xo), " GT max of ", @max_x, ")\n"
         xo = @max_x
       elsif (xo < @min_x)
         cncPrint "(move x=", sprintf("%8.3f",xo), " LT min of ", @min_x, ")\n"
         xo = @min_x
       end #if
       if (yo > @max_y)
         cncPrint "(move y=", sprintf("%8.3f",yo), " GT max of ", @max_y, ")\n"
         yo = @max_y
       elsif (yo < @min_y)
         cncPrint "(move y=", sprintf("%8.3f",yo), " LT min of ", @min_y, ")\n"
         yo = @min_y
       end #if
       if (zo > @max_z)
         cncPrint "(move z=", sprintf("%8.3f",zo), " GT max of ", @max_z, ")\n"
         zo = @max_z
       elsif (zo < @min_z)
         cncPrint "(move x=", sprintf("%8.3f",zo), " LT min of ", @min_z, ")\n"
         zo = @min_z
       end #if


       if ((xo != @cx) && (yo != @cy) && (zo != @cz))
         cncPrint "G01 X", sprintf("%8.3f", xo), " Y", sprintf("%8.3f", yo)," Z", sprintf("%8.3f", zo), " F", so, "\n"
       elsif ((xo != @cx) && (yo != @cy))
         cncPrint "G01 X", sprintf("%8.3f", xo), " Y",sprintf("%8.3f", yo)," F", so, "\n"
       elsif ((xo != @cx) && (zo != @cz))
         cncPrint "G01 X", sprintf("%8.3f", xo), " Z",sprintf("%8.3f", zo)," F", so, "\n"
       elsif ((yo != @cy) && (zo != @cz))
         cncPrint "G01 Y", sprintf("%8.3f", yo), " Z",sprintf("%8.3f", zo)," F", so, "\n"
       elsif (xo != @cx) 
         cncPrint "G01 X",sprintf("%8.3f", xo)," F", so, "\n"
       elsif (yo != @cy) 
         cncPrint "G01 Y",sprintf("%8.3f", yo)," F", so, "\n"
       elsif (zo != @cz) 
         cncPrint "G01 Z",zo," F", so, "\n"
       else
         cncPrint "G01 X", sprintf("%8.3f", xo), " Y",sprintf("%8.3f", yo)," Z",sprintf("%8.3f", zo)," F", so, "\n"
       end
         
       @cx = xo
       @cy = yo
       @cz = zo
     end #if
   end #meth


   # - - - - - - - - - - - - - - - - - -
   def cz
   # - - - - - - - - - - - - - - - - - -  
     @cz
   end #meth

   # - - - - - - - - - - - - - - - - - -
   def cx
   # - - - - - - - - - - - - - - - - - -  
     @cx
   end #meth

   # - - - - - - - - - - - - - - - - - -
   def cy
   # - - - - - - - - - - - - - - - - - -  
     @cy
   end #meth


   # - - - - - - - - - - - - - - - -     
   def current_bit(aBit=nil)
   # - - - - - - - - - - - - - - - -      
     if aBit != nil
       @curr_bit = aBit
     end #if
     @curr_bit
   end

   # - - - - - - - - - - - - - - - -
   def bit_radius
   # - - - - - - - - - - - - - - - -
     @curr_bit.radius
   end #meth

   # - - - - - - - - - - - - - - - -
   def bit_diam
   # - - - - - - - - - - - - - - - -
     @curr_bit.diam
    end #meth

	def set_bit_diam(diameter)
		@curr_bit.diam = diameter
	end
	
  # - - - - - - - - - - - - - - - -
  def flute_len
  # - - - - - - - - - - - - - - - -  
     @curr_bit.flute_len
  end #meth

  # - - - - - - - - - - - - - - - -
  def cut_increment
  # - - - - - - - - - - - - - - - -
    # TODO: Modify this so that it gets
    #   the cut increment based on current
    #   speed setting finish or rough
    #   and material selected.  The cutting
    #   bit should calculate this by using
    #   the material that it can obtain
    #   from the mill.
    return @curr_bit.cut_increment_rough
   end #meth


   # - - - - - - - - - - - - - - - -
  def cut_increment_rough
  # - - - - - - - - - - - - - - - -
    @curr_bit.cut_increment_rough
   end #meth

   # - - - - - - - - - - - - - - - -
   def cut_increment_finish
   # - - - - - - - - - - - - - - - -  
     @curr_bit.cut_increment_finish
   end #meth 


   # Returns the current cutting 
   # depth increment.  This is based
   # on the current material, type 
   # of bit,  size of mill and 
   # whether finish cutting or rough
   # cutting.   The mill will make this
   # number have to make a number of
   # passes to make deeper cuts and the
   # total number is generally calculated
   # by dividing total depth of cut by
   # this number.   The method 
   # set_speed_finish will generally cause
   # this method to returrn a smaller number
   # than when set_speed_rough is used.
   # - - - - - - - - - - - - - - - -
   def cut_depth_inc_curr
   # - - - - - - - - - - - - - - - -  
     return @curr_bit.cut_depth_inc_curr
     # TODO: enhance this so that it
     #   is using bit and material
     #   knowledge to determine proper
     #   cut depth.
   end #meth 

   # - - - - - - - - - - - - - - - -
   def cut_depth_rough
   # - - - - - - - - - - - - - - - -  
     @curr_bit.cut_depth_rough
   end #meth 

   # - - - - - - - - - - - - - - - -
   def cut_depth_finish
   # - - - - - - - - - - - - - - - -  
     @curr_bit.cut_depth_finish
   end #meth 


   # - - - - - - - - - - - - - - - -     
   def move_y(yo, zo=@cz, so=@speed_curr)
   # - - - - - - - - - - - - - - - -     
     move(@cx,yo,zo,so)
   end #meth
     
     
   # - - - - - - - - - - - - - - - -     
   def move_z(zo, so=@speed_curr)
   # - - - - - - - - - - - - - - - -     
     move(@cx,@cy,zo,so)
   end #meth
     
     
   # - - - - - - - - - - - - - - - -     
   def retract(depth = @retract_depth)
   # - - - - - - - - - - - - - - - -     
     if (depth == nil)
       depth = @retract_depth
     end #if
     if (@cz == depth)
       @no_move_count += 1
     else
       if (depth > @max_z)
         depth = @max_z
       elsif (depth < @min_z)
         depth = @min_z
       end #else
      
       cncPrint "G00 Z",sprintf("%8.3f", depth) , "\n"
       @cz = depth
     end #else
   end #meth


   # - - - - - - - - - - - - - - - -
   def plung(depth = @mill_depth)
   # - - - - - - - - - - - - - - - -     
     if (mill_depth == @cz)
        @no_move_count += 1
     else
       if (depth > @max_z)
         depth = @max_z
       elsif (depth < @min_z)
         depth = @min_z
       end #if

       cncPrint "G01 Z", sprintf("%8.3f", depth), " F", @speed_plung, "\n"
       @cz = depth
     end #if
   end #meth



   # - - - - - - - - - - - - - - - -     
   def  mill_depth(depth=nil)
   # - - - - - - - - - - - - - - - -     
     if (depth != nil)
        if (depth < @max_z)
           depth =   @max_z
        elsif (depth < @min_z)
           depth = @min_z
        end #if
        @mill_depth = depth
     end #if
     @mill_depth
   end #meth
    
   # - - - - - - - - - - - - - - - -    
   def speed
   # - - - - - - - - - - - - - - - -     
     return @speed_curr 
   end # meth
    

   # - - - - - - - - - - - - - - - -    
   def set_speed(speed)
   # - - - - - - - - - - - - - - - -     
     if (speed != nil)
       if ((speed > 0) && (speed < @speed_max))
         @speed_curr = speed
       end #if
     end #if
   end # meth


   # - - - - - - - - - - - - - - - -    
   def set_speed_rough
   # - - - - - - - - - - - - - - - -     
     set_speed(@speed_normal)
   end # meth

   # - - - - - - - - - - - - - - - -    
   def set_speed_finish
   # - - - - - - - - - - - - - - - -     
     set_speed(@speed_finish)
   end # meth



   # - - - - - - - - - - - - - - - -
   def home
   # - - - - - - - - - - - - - - - - 
     if (@cx == @retract_depth) && (@cy == 0) && (@cz == 0)
       @no_move_count += 1
     else
       retract
       cncPrint "G00 X0 Y0\n"
       @cx = 0
       @cy = 0
     end #if
   end #meth



   # - - - - - - - - - - - - - - - -
   def min_y=(aObj)
   # - - - - - - - - - - - - - - - - 
     @min_y  = aObj
   end #meth
   # - - - - - - - - - - - - - - - -
   def min_y
   # - - - - - - - - - - - - - - - - 
     return @min_y
   end # meth
   # - - - - - - - - - - - - - - - -
   def max_y=(aObj)
   # - - - - - - - - - - - - - - - - 
     @max_y  = aObj
   end #meth
   # - - - - - - - - - - - - - - - -
   def max_y
   # - - - - - - - - - - - - - - - - 
     return @max_y
   end # meth



   # - - - - - - - - - - - - - - - -
   def min_x=(aObj)
   # - - - - - - - - - - - - - - - - 
     @min_x  = aObj
   end #meth
   # - - - - - - - - - - - - - - - -
   def min_x
   # - - - - - - - - - - - - - - - - 
     return @min_x
   end # meth
   # - - - - - - - - - - - - - - - -
   def max_x=(aObj)
   # - - - - - - - - - - - - - - - - 
     @max_x  = aObj
   end #meth
   # - - - - - - - - - - - - - - - -
   def max_x
   # - - - - - - - - - - - - - - - - 
     return @max_x
   end # meth



   # - - - - - - - - - - - - - - - -
   def min_a=(aObj)
   # - - - - - - - - - - - - - - - - 
     @min_z  = aObj
   end #meth
   # - - - - - - - - - - - - - - - -
   def min_z
   # - - - - - - - - - - - - - - - - 
     return @min_z
   end # meth
   # - - - - - - - - - - - - - - - -
   def max_z=(aObj)
   # - - - - - - - - - - - - - - - - 
     @max_z  = aObj
   end #meth
   # - - - - - - - - - - - - - - - -
   def max_z
   # - - - - - - - - - - - - - - - - 
     return @max_z
   end # meth





   # - - - - - - - - - - - - - - - -     
   def move_fast(xo,yo=@cy,zo=@cz)
   # - - - - - - - - - - - - - - - - 
     if (xo == @cx) && yo = @cz  && (zo == @cz)
       @no_move_count += 1
     else
       if (xo > @max_x)
         xo = @max_x
       elsif (xo < @min_x)
         xo = @min_x
       end #if
       if (yo > @max_y)
         yo = @max_y
       elsif (yo < @min_y)
         yo = @min_y
       end #if
       if (zo > @max_z)
         zo = @max_z
       elsif (zo < @min_z)
         zo = @min_z
       end #if
       cncPrint "G00 X",sprintf("%8.3f", xo),  " Y",sprintf("%8.3f", yo), " Z",sprintf("%8.3f", zo)  , " (move fast)\n"
       @cx = xo
       @cy = yo
       @cz = zo 
     end # if
   end #meth



   # Mill a rectangle between the coordinates
   # specified.   The caller is responsible for either
   # pre-positioning the bit inside the rectangle
   # or retracting it prior to the call.   This method
   # does not supply any layer or flute length support
   # because it is normally called by higher level methods 
   # that do.    Used current speed which can be changed
   # by calling set_speed prior to calling this method
   # - - - - - - - - - - - - - - - -     
   def mill_rect(lx, ly, mx, my, depth, adjust_for_bit_radius=false)
   # - - - - - - - - - - - - - - - -
     # if needed swap lx and mx to ensure that
     # lx is the smaller number
      if (lx > mx)
        tt = lx
        llx = mx
        mx = tt
     end
      
     # if needed swap ly,my to make sure that
     # ly is the lower number.
     if (ly > my)
       tt = ly
       lly = my
       my = tt
     end


     if (adjust_for_bit_radius == true)
       lbr = bit_radius
       llx = lx + br
       lly = ly + br
       mx = mx - br
       my = my - br
     end

     # if our point is already inside the defined rectangle
     # then we assume it is safe to move without a retract
     if ((@cx < lx) || (@cx > mx) || (@cy < ly) || (@cy > my))
        rretract()
     end

     # walk around the perimiter of the sqare
     move(lx,ly)
     plung(depth)  # if already at correct depth will
                         # just ignore
     move(lx,ly)
     move(lx,my)
     move(mx,my)
     move(mx,ly)
     move(lx,ly)

   end #meth

   # Mill a simple rectangle the diameter of the
   # the milling bit that follows the coordinates
   # speicified.   The caller is responsible to 
   # either pre-position the bit or retract the 
   # bit prior to calling.   This method
   # does not supply any layer or flute length support
   # because it is normally called by higher level methods 
   # that do.
   # - - - - - - - - - - - - - - - -     
   def mill_rect_centered(scx,scy,width,length, depth)
   # - - - - - - - - - - - - - - - -i
     lx = to_f(scx) - (width  / 2)  
     ly = to_f(scy) - (length / 2)
     mx = to_f(scx) + (width  / 2)
     my = to_f(scy) + (length / 2)
     mill_rect(lx,ly,mx,my, depth)
   end #meth

   # uses simple  trig function to calculate
   # distance between two points
   # - - - - - - - - - - - - - - - - - -
   def calc_distance(x1,y1,x2=@cx,y2=@cy)
   # - - - - - - - - - - - - - - - - - -
      #print "(calc_distance x1=", x1, " y1=", y1, " x2=", x2, " y2=", y2, ")\n"
      # TODO: Figure out how to call the cncGeometry version
      #   even though we have a name conflict.
      dx = (to_f(x1) - x2).abs
      dy = (to_f(y1) - y2).abs
      tdist =  Math.sqrt((dx*dx) + (dy*dy))
      return tdist
   end #meth

   

   # returns a point adjusted to 
   # fit the current max extents 
   # active for the mill. 
   # - - - - - - - - - - - - - - - - - -
   def apply_limits(xo, yo, zo=nil)
   # - - - - - - - - - - - - - - - - - -
     if (yo > @max_y)
       yo = @max_y
     end #if
     if (yo < @min_y)
       yo = @min_y
     end #if


     if (xo > @max_x)
       xo = @max_x
     end #if
     if (xo < @min_x)
       xo = @min_x
     end #if

     if (zo != nil)
       if (zo > @max_z)
         zo = @max_z
       end #if
       if (zo < @min_z)
         zo = @min_z
       end #if
     end #if


     np = CNCPoint.new(xo,yo,zo)
     return np
   end #meth



end # class
