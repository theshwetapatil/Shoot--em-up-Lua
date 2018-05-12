-- test the bsp module
bsp=require('bsp')
vector=require('vector')

function makeRandomPoints ( n )
   n = n or 1000

   local pts = {}
   for i=1,n do
      table.insert(pts, vector.new(math.random(0,100),math.random(0,100)))
   end
   return pts
end

function findWithin ( pts, pt, r )
   found={}
   for i,p in ipairs(pts) do
      if p:dist(pt) < r then
        table.insert(found,p)
      end
   end
   return found
end

function test()
   local pts = makeRandomPoints()
   local t = bsp.build(pts)

   -- try to get all the points
   print('testing big query:')
   local got = bsp.withinDisk ( t, vector.new(50,50), 100 )
   if #got ~= #pts then
      print('FAIL')
   else
      print('PASS')
   end

   -- try to get some
   print('testing small query:')
   local pt = vector.new(50,50)
   local r = 10
   local got = bsp.withinDisk ( t, pt, r )
   local gotbruteforce = findWithin(pts, pt, r)
   if #got ~= #gotbruteforce then
      print('FAIL')
   else
      print('PASS')
   end
end

math.randomseed(os.time())
test()