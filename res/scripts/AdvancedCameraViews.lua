local transf = require "transf"
local vec3 = require "vec3"

local function viewRotTransl (rotZYX,translXYZ,foV)
	return {
		transf = transf.rotZYXTransl(
			transf.degToRad( rotZYX[1], rotZYX[2], rotZYX[3] ),
			vec3.new( translXYZ[1], translXYZ[2], translXYZ[3] ) 
		),  -- group = 0 can be left out
		fov = foV  -- can also be left out (nil)
	}
end

local function defaultView (x,z,fov)  -- add default camera view because it's replaced
	return viewRotTransl( {0, 0, 0 }, {x, 0, z }, fov )
end

local function fromTopView (z,rot)
	local rotZ=0
	if rot then
		rotZ=180
	end
	return viewRotTransl( {rotZ, 90, 0 }, {0, 0, z }, 60 )
end

local function getOptions()
	if merk_modutil and merk_modutil[1] then
		return merk_modutil[1].userSettings.get("Advanced_Camera_Views_1")
	else
		print("No merk_modutil !")
	end
end

local function optionalViews(views, include)
	if include==true then
		return views
	else
		return {}
	end
end

local function addSeat (seat,vectransl)  -- add one view by a seat with transl
	local tran = transf.mul(seat.transf, transf.transl(vectransl))
	return { group=seat.group, transf = tran }
end

local function addSeats (seatProvider)  -- add driver seat(s) and one passenger seat
	local seats={}
	if seatProvider and seatProvider.seats then
		local passseatset=false
		local crewseatset=false
		local options = getOptions()
		if not options.addCrewSeats then
			print("AdvancedCameraViews: options=={}")
		end
		for _,seat in pairs(seatProvider.seats) do
			if seat.crew==true then  -- crew
				if options.addCrewSeats==true then
					if seat.animation == "idle" then  -- standing
						table.insert(seats, addSeat(seat, vec3.new(-0.7, 0, 1.7)))
						crewseatset=true
					end
					if seat.animation == "driving_upright" or seat.animation == "driving" or seat.animation == "sitting" then  -- sitting
						table.insert(seats, addSeat(seat, vec3.new(-1, 0, 1.4)))
						crewseatset=true
					end
				end
			else  -- passenger
				if options.addPassengerSeats==true then
					if passseatset==false and seat.animation == "sitting" and seat.forward==true then  -- add first forward sitting passenger
						table.insert(seats, addSeat(seat, vec3.new(-0.7, 0, 1.4)))
						passseatset=true
					end
				end
			end
		end
	end
	return seats
end


local camViews={}

camViews.TrainViews = function (xmax,ymax,zmax,xmin,ymin,zmin,data) return {
	defaultView(xmax, 3),
	viewRotTransl( {-150,	0,	0	},	{xmax+12,	10,			2.5	},	50 ),
	viewRotTransl( {150,	0,	0	},	{xmax+12,	-10,		2.5	},	50 ),
	viewRotTransl( {0,		15,	0	},	{-100,		0,			25	},	50 ),
	viewRotTransl( {180,	15,	0	},	{50,		0,			15	},	50 ),
	viewRotTransl( {90,		15,	0	},	{0,			-50,		15	},	60 ),
	viewRotTransl( {-90,	15,	0	},	{0,			50,			15	},	60 ),
	addSeats(data.metadata.seatProvider),
	viewRotTransl( {-20,	0,	0	},	{xmin+4,	ymin-0.1,	3	},	50 ),
	viewRotTransl( {20,		0,	0	},	{xmin+4,	ymax+0.1,	3	},	50 ),
	viewRotTransl( {0,		0,	0	},	{-3,		0,			5	},	60 ),
	viewRotTransl( {0,		0,	0	},	{0,			ymin-0.2,	0.6	},	50 ),
	viewRotTransl( {0,		0,	0	},	{0,			ymax+0.2,	0.6	},	50 ),
	viewRotTransl( {0,		25,	0	},	{-280,		0,			90	},	60 ),
	viewRotTransl( {180,	25,	0	},	{170,		0,			90	},	60 ),
	viewRotTransl( {90,		25,	0	},	{0,			-170,		90	},	60 ),
	viewRotTransl( {-90,	25,	0	},	{0,			170,		90	},	60 ),
	fromTopView(650),
} end

camViews.WaggonViews = function (xmax,ymax,zmax,xmin,ymin,zmin,data) return {
	viewRotTransl( {0,		0,	0	},	{-2,	0,		zmax+0.7	},	60 ),
--	viewRotTransl( {90,		15,	0	},	{0,		-50,	15			},	50 ),
--	viewRotTransl( {-90,	15,	0	},	{0,		50,		15			},	50 ),
	addSeats(data.metadata.seatProvider),
} end

camViews.TramViews = function (xmax,ymax,zmax,xmin,ymin,zmin,data) return {
	defaultView(xmax, 2.2),
	viewRotTransl( {-10,	5,	0	},	{xmin-5,ymax+2,		3.5	},	60 ),
	viewRotTransl( {190,	5,	0	},	{xmax+5,ymax+2,		3.5	},	60 ),
	viewRotTransl( {-15,	0,	0	},	{xmin-2,ymin-0.5,	2	},	60 ),
	viewRotTransl( {-165,	0,	0	},	{xmax+2,ymin-0.5,	2	},	60 ),
	viewRotTransl( {0,		0,	0	},	{0,		0,			4	},	60 ),
	addSeats(data.metadata.seatProvider),
	viewRotTransl( {0,		35,	0	},	{-90,	0,			70	},	60 ),
	viewRotTransl( {180,	35,	0	},	{90,	0,			70	},	60 ),
	viewRotTransl( {90,		35,	0	},	{0,		-90,		70	},	60 ),
	viewRotTransl( {-90,	35,	0	},	{0,		90,			70	},	60 ),
} end

camViews.RoadViews = function (xmax,ymax,zmax,xmin,ymin,zmin,data) return {
	defaultView(xmax, 2),
	viewRotTransl( {0,		10,	0	},	{xmin-8,0,		zmax+1	},	60 ),
	viewRotTransl( {180,	10,	0	},	{xmax+8,0,		zmax+1	},	60 ),
	viewRotTransl( {90,		15,	0	},	{0,		-10,	zmax+2	},	60 ),
	viewRotTransl( {-90,	15,	0	},	{0,		15,		zmax+3	},	60 ),
	addSeats(data.metadata.seatProvider),
	viewRotTransl( {0,		0,	0	},	{xmin+1	,0,		zmax+0.5},	50 ),
	fromTopView(100)
} end

camViews.CarViews = function (xmax,ymax,zmax,xmin,ymin,zmin,data) return {
	defaultView(xmax, 1.5, 50),
	viewRotTransl( {0,		10,	0	},	{xmin-8,	0,	zmax+1	},	60 ),
	viewRotTransl( {180,	10,	0	},	{xmax+8,	0,	zmax+1	},	60 ),
	viewRotTransl( {90,		15,	0	},	{0,			-10,zmax+2	},	60 ),
	viewRotTransl( {-90,	15,	0	},	{0,			15,	zmax+3	},	60 ),
	addSeats(data.metadata.seatProvider),
	viewRotTransl( {0,		0,	0	},	{xmin+0.4,	0,	zmax+0.5},	50 ),
	fromTopView(80)
} end

camViews.ShipViews = function (xmax,ymax,zmax,xmin,ymin,zmin,data) return {
	defaultView(xmax, zmax/2),
	viewRotTransl( {-150,	0,	0	},	{xmax+24,	ymax+15,	5	},	50 ),
	viewRotTransl( {150,	0,	0	},	{xmax+24,	ymin-15,	5	},	50 ),
	viewRotTransl( {0,		20,	0	},	{xmin-50,	0,			30	},	50 ),
	viewRotTransl( {180,	20,	0	},	{xmax+50,	0,			30	},	50 ),
	viewRotTransl( {90,		20,	0	},	{0,			ymin-50,	25	},	60 ),
	viewRotTransl( {-90,	20,	0	},	{0,			ymax+50,	25	},	60 ),
	addSeats(data.metadata.seatProvider),
	fromTopView(120),
	fromTopView(700)
} end

camViews.PlaneViews = function (xmax,ymax,zmax,xmin,ymin,zmin,data) return {
	defaultView(xmax, (zmax+zmin)/2 ),
	viewRotTransl( {0,		30,	0	},	{xmin-20,	0,		zmax+10	},	50 ),
	viewRotTransl( {180,	30,	0	},	{xmax+20,	0,		zmax+10	},	50 ),
	viewRotTransl( {90,		20,	0	},	{0,			ymin-20,zmax+5	},	50 ),
	viewRotTransl( {-90,	20,	0	},	{0,			ymax+20,zmax+5	},	50 ),
	viewRotTransl( {0,		0,	0	},	{xmin+10,	0,		zmax-2	},	60 ),
	viewRotTransl( {0,		0,	0	},	{xmin+10,	0,		zmin+1	},	60 ),
	addSeats(data.metadata.seatProvider),
	fromTopView(zmax+50),
	viewRotTransl( {180,	-30,0	},	{xmax+15,	0,		zmin-12	},	60 ),
	viewRotTransl( {180,	-90,0	},	{0,			0,		zmin-50	},	60 ),
	viewRotTransl( {0,		-30,0	},	{xmin-15,	0,		zmin-12	},	60 ),
	fromTopView(300)
} end

camViews.PersonViews = function (xmax,ymax,zmax,xmin,ymin,zmin,data) return {
	defaultView(xmax, zmax, 50),
	viewRotTransl( {0,		10,	0	},	{-6,0,	2.5	},	50 ),
	viewRotTransl( {180,	10,	0	},	{6,	0,	2.5	},	50 ),
	viewRotTransl( {-90,	15,	0	},	{0,	6,	2.5	},	50 ),
	viewRotTransl( {90,		15,	0	},	{0,	-6,	2.5	},	50 ),
	fromTopView(40)
} end

camViews.AnimalViews = function (xmax,ymax,zmax,xmin,ymin,zmin,data) return {
	-- Animal mdl's have already one camera view inlcuded
	viewRotTransl( {0,		10,	0	},	{xmin-9,0,	zmax+1	},	60 ),
	viewRotTransl( {180,	10,	0	},	{xmax+9,0,	zmax+1	},	60 ),
	viewRotTransl( {0,		45,	0	},	{-30,	0,	25		},	60 ),
	viewRotTransl( {180,	45,	0	},	{30,	0,	25		},	60 ),
	viewRotTransl( {90,		45,	0	},	{0,		-30,25		},	60 ),
	viewRotTransl( {-90,	45,	0	},	{0,		30,	25		},	60 ),
	fromTopView(80)
} end

return camViews