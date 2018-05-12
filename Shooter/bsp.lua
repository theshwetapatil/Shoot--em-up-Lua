-- a bsp tree for points with circular range queries
-- better described as a k-d tree, using points as splitters, and alternating axes.

local BSP = {}
BSP.__index=BSP

function BSP.build ( pts, axis )
   axis = axis or 'x'

   if #pts == 0 then
      return nil
   end

   -- pick splitter
   local splitter = pts[math.random(1,#pts)]

   -- partition the points
   local back = {}
   local front = {}
   local inplane = {}

   for i = 1, #pts do
      if pts[i][axis] < splitter[axis] then
        table.insert ( back, pts[i] )
      elseif pts[i][axis] > splitter[axis] then
        table.insert ( front, pts[i] )
      else
        table.insert(inplane,pts[i])
      end
   end

   -- set axis for next level of tree
   axis = axis == 'x' and 'y' or 'x'

   -- return an internal BSP tree node, recurse for children
   local retval =  { splitter= splitter,
		     inplane = inplane,
		     left    = BSP.build ( back, axis ),
		     right   = BSP.build ( front, axis )   }
   return retval
end

function BSP.concat ( t1, t2 )
   -- add the integer-indexed elements of t2 to the end of t1
   if t1 and t2 then
      for _,vec in pairs(t2) do
	     table.insert ( t1, vec )
      end
      return t1
   elseif t1==nil and t2 ~= nil then
      return t2
   elseif t1~=nil and t2==nil then
      return t1
   else
      return nil
   end
end

function BSP.inCircle ( pt,r,pts )
   local found = {}
   for _,p in pairs(pts) do
      local dx=p.x-pt.x
      local dy=p.y-pt.y
      if dx*dx + dy*dy < r*r then
        table.insert ( found, p )
      end
   end
   return found
end

function BSP.withinDisk ( bsp, pt, r, axis )
   axis = axis or 'x'

   local found
   local nextAxis=axis=='x' and 'y' or 'x'
   if bsp then
      if bsp.splitter[axis] < pt[axis] - r then
        found = BSP.withinDisk ( bsp.right, pt, r, nextAxis )
      elseif bsp.splitter[axis] > pt[axis] + r then
        found = BSP.withinDisk ( bsp.left, pt, r, nextAxis )
      else
        found = BSP.concat ( BSP.concat ( BSP.withinDisk ( bsp.left, pt, r, nextAxis ),
                                          BSP.withinDisk ( bsp.right, pt, r, nextAxis ) ),
                                          BSP.inCircle ( pt, r, bsp.inplane ) )
      end
   end
   return found
end

-- the module
return BSP
