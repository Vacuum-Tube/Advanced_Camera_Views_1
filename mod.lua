local tools = require "vTube_tools"

local crewPositions = {0}
local function getDefaulModParams()
	local function setCrewPositions(entry)
		entry.values = {tostring(0)}
		local step = 0.05
		local count = 30
		local default = -0.75
		for i = 1, count do
			table.insert(crewPositions, step * i)
			table.insert(entry.values, tostring(step * i))
			table.insert(crewPositions, 1, -1 * step * i)
			table.insert(entry.values, 1, tostring(-1 * step * i))
		end
		entry.defaultIndex = (default / step) + count
	end
	--------------------------------------------------
	-- Hier geht's los :)
	--------------------------------------------------
	local result = {}
	
	result[#result + 1] = {
		key = "replaceExistingViews",
		name = _("Replace Existing Cameraviews"),
		tooltip = _("replaceExistingViews"),
		uiType = "COMBOBOX",
		values = { _("Vorhandene ersetzen"), _("Neue am Anfang platzieren"), _("Neue am Ende platzieren")},
		defaultIndex = 1,
	}
	result[#result + 1] = {
		key = "addCrewSeats",
		name = _("Add Crew Seats"),
		tooltip = _("addCrewSeats"),
		uiType = "BUTTON",
		values = { _("Yes"), _("No")},
		defaultIndex = 0,
	}
	
	result[#result + 1] = {
		key = "posCrewSeats",
		name = _("Position Crew Seats"),
		tooltip = _("posCrewSeats"),
		uiType = "SLIDER",
	}
	setCrewPositions(result[#result])
	
	result[#result + 1] = {
		key = "addPassengerSeats",
		name = _("Add Passenger Seats"),
		tooltip = _("addPassengerSeats"),
		uiType = "BUTTON",
		values = { _("Yes"), _("No")},
		defaultIndex = 0,
	}
	result[#result + 1] = {
		key = "addPersonViews",
		name = _("Add Person Views"),
		tooltip = _("addPersonViews"),
		uiType = "BUTTON",
		values = { _("Yes"), _("No")},
		defaultIndex = 1,
	}
	
	return result
end
local defaulModParams = getDefaulModParams()

function data()
	return {
		info = {
			name = _("name"),
			description = _("desc"),
			minorVersion = 7,
			severityAdd = "NONE",
			severityRemove = "NONE",
			tfnetId = 5224,
			tags = {"Script Mod","Camera","Camera View","Vehicle","Locomotive","Multiple Unit","Bus","Truck","Tram","Ship","Plane","Car","Person","Animal","Misc"},
			authors = {
				{
					name = "VacuumTube",
					role = "CREATOR",
					tfnetId = 29264,
				},
			},
		params = defaulModParams,
		},
		runFn = function(settings, modParams)
			tools.saveModParams("paramsACV", modParams, defaulModParams)
			tools.modParams("paramsACV").crewPositions = crewPositions
			addModifier("loadModel", require "addCameraPositions")
		end
	}
end