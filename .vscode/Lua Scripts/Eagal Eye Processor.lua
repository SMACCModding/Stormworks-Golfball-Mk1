targetCountMax = property.getNumber("Max Target")
colourR = property.getNumber("R")
colourG = property.getNumber("G")
colourB = property.getNumber("B")
outlineSize = property.getNumber("Rectangle Size")
set = property.getNumber("Target Info")
offsetX = property.getNumber("Offset X")
offsetY = property.getNumber("Offset y")

screenW=0
screenH=0
min = 0
zoom = 0

isum = {}
dis = {}
xv = {}
yv = {}
x = {}
y = {}
s = {}
d = {}
v = {}
la = {}
lm = {}
ms = {}
td = {}
ts = {}
on = {}


xavg = {}
yavg = {}
davg = {}
iavg = {}
od = {}
ri = {}
cmp = {}
cmpx = {}
cmpy = {}
xyp = {}
function Table( num )
	for i = 1, num do
        xavg[i] = 0
        yavg[i] = 0
        davg[i] = 0
        iavg[i] = 0
        od[i] = 0
        ri[i] = {}
        cmp[i] = {}
        cmpx[i] = {}
        cmpy[i] = {}
        xyp[i] = 0
	end
end

Table(targetCountMax)

function clamp( min, max, value )
  return math.min( max, math.max( min, value ) )
end

fov = 120
function onTick()

	camx = clamp( -1, 1, input.getNumber(30) )
	camy = clamp( -1, 1, input.getNumber(31) )
	zoom = clamp( 0, 1, input.getNumber(32) )
	ang = math.max( fov * ( 1 - zoom ), 1 )
	zx = math.tan( ang * math.pi / 180 / 2 ) / ( 1.82 - 0.15 * ( screenW / screenH - 1 ) )
	zy = math.tan( ang * math.pi / 180 / 2 ) / 1.82

	for i = 1, targetCountMax do
        n = i + ( i - 1 ) * 3
        dis[i] = input.getNumber( n )
        xv[i] = input.getNumber( n+1 )
        yv[i] = input.getNumber( n+2 )
        td[i] = input.getBool( i )
        Cal( i )
	end

end

function Cal( num )

	v[num] = math.min( math.floor( dis[num] ) / 1000, 0.8 )
	xavg[num] = xavg[num] * v[num] + xv[num]  * (1 - v[num])
	yavg[num] = yavg[num] * v[num] + yv[num]  * (1 - v[num])
	davg[num] = davg[num] * v[num] + dis[num] * (1 - v[num])

	isum[num] = 0
	ts[num] = math.min( math.floor( davg[num] / 5 ), 150 )
	table.insert( ri[num], davg[num] )
	if #ri[num] > ts[num] then
	    table.remove( ri[num], 1 )
	end
	for i = 1, #ri[num] do
	    isum[num] = isum[num] + ri[num][i]
	end
	iavg[num] = isum[num] / #ri[num]

	a = math.floor( davg[num] )
	b = 1 - ( a / 5000 )
	c = 1 / ( a / ( 5 - ( b * 2.5 ) ) )

	xco = math.tan( math.rad( xavg[num] * 360 - camx * 45 ) ) * ( screenW / 4 / zx ) * ( screenH / screenW ) + screenW / 2
	yco = -math.tan( math.rad( yavg[num] * 360 - camy * 45 ) ) * ( screenH / 4 / zy ) + screenH / 2
	size = math.max( outlineSize * c * ( screenW / 32 ), 0 ) * ( fov / ang ) * ( screenH / screenW )
	ms[num] = -math.floor( ( ( iavg[num] - od[num] ) / 0.016 ) / 1 ) -- This looks weird, do we need // ?
	od[num] = iavg[num]

	lena = 2 - string.len( a ) * 2.5
	lenm = -2 - string.len( ms[num] ) * 2.5

	x[num] = xco
	y[num] = yco
	s[num] = size
	d[num] = a
	la[num] = lena
	lm[num] = lenm

end

function onDraw()
	screenW = screen.getWidth()
	screenH = screen.getHeight()
	screenCenterW = screenW / 2
	screenCenterH = screenH / 2

	for i = 1, targetCountMax do
		for j = 1, targetCountMax do
			if not (i == j) then
				cmp[i][j] = math.abs(d[i]-d[j])
				cmpx[i][j] = math.abs(x[i]-x[j])
				cmpy[i][j] = math.abs(y[i]-y[j])
			end
			if ( ( cmp[i][j] or 16 ) < 15 and ( cmp[i][j] or -1 ) >= 0 ) and ( cmpx[i][j] <= s[i] and cmpy[i][j] <= s[i] ) then
				td[j] = false
			end
		end
	end

	xyp[i] = math.abs( screenCenterW - math.floor( x[i] ) ) + math.abs( screenCenterH - math.floor( y[i] ) )
	min = xyp[i]
	for j = 1, targetCountMax do
		if min >= xyp[j] and td[j] then
			min = xyp[j]
		end
	end

	if ( min + screenH / 32 + 0.5 ) > xyp[i] and td[i] then
		on[i] = true
	else
		on[i] = false
	end

	if td[i] then
		if on[i] then
			if set == 1 or set == 3 then
				screen.setColor( colourR, colourG, colourB, 255)
				screen.drawText(x[i]+lm[i]+offsetX,y[i]-s[i]/2-6+offsetY,ms[i] .. "m/s")
			end
			if set == 1 or set == 2 then
				if d[i] > 1000 then
					screen.drawText( x[i] + la[i] + offsetX, y[i] + s[i] / 2 + 3 + offsetY, string.format( "%0.1f", d[i] / 1000 ) )
				else
					screen.drawText( x[i] + la[i] + offsetX, y[i] + s[i] / 2 + 3 + offsetY, d[i] )
				end
			end
		else
			screen.setColor( colourR, colourG, colourB, 200 )
		end
		screen.drawRect( x[i] - s[i] / 2 + offsetX, y[i] - s[i] / 2 + offsetY, s[i] ,s[i] )
		screen.setColor( colourR, colourG, colourB, 255 )
	end
end