local tools = require "vTube_tools"

local crewPositions = {0}
local function setCrewPositions(entry)
	entry.values = {tostring(0)}
	local step = 0.05
	local count = 30
	local default = -0.8
	for i = 1, count do
		table.insert(crewPositions, step * i)
		table.insert(entry.values, tostring(step * i))
		table.insert(crewPositions, 1, -1 * step * i)
		table.insert(entry.values, 1, tostring(-1 * step * i))
	end
	entry.defaultIndex = (default / step) + count
end

local defaultModParams = (function()
	local result = {}
	result[#result + 1] = {
		key = "replaceExistingViews",
		name = _("replaceExistingViewsNAME"),
		tooltip = _("replaceExistingViewsTT"),
		uiType = "COMBOBOX",
		values = { _("Replace existing"), _("Place new at the beginning"), _("Place new at the end")},
		defaultIndex = 1,
	}
	result[#result + 1] = {
		key = "addCrewSeats",
		name = _("addCrewSeatsNAME"),
		tooltip = _("addCrewSeatsTT"),
		uiType = "BUTTON",
		values = { _("Yes"), _("No")},
		defaultIndex = 0,
	}
	-- result[#result + 1] = {
		-- key = "posCrewSeats",
		-- name = _("posCrewSeatsNAME"),
		-- tooltip = _("posCrewSeatsTT"),
		-- uiType = "SLIDER",
	-- }
	-- setCrewPositions(result[#result])
	result[#result + 1] = {
		key = "addPassengerSeats",
		name = _("addPassengerSeatsNAME"),
		tooltip = _("addPassengerSeatsTT"),
		uiType = "BUTTON",
		values = { _("Yes"), _("No")},
		defaultIndex = 0,
	}
	result[#result + 1] = {
		key = "addPersonViews",
		name = _("addPersonViewsNAME"),
		tooltip = _("addPersonViewsTT"),
		uiType = "BUTTON",
		values = { _("Yes"), _("No")},
		defaultIndex = 1,
	}
	return result
end)()

function data()
	return {
		info = {
			name = _("name"),
			description = _("desc"),
			minorVersion = 9,
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
				{
					name = "EAT1963",
					role = "CO_CREATOR",
					tfnetId = 19725,
				},
			},
			params = defaultModParams,
		},
		runFn = function(settings, modParams)
			tools.saveModParams("paramsACV", modParams, defaultModParams)
			
			local entry = {}
			setCrewPositions(entry)
			tools.modParams("paramsACV").posCrewSeats = entry.defaultIndex
			tools.modParams("paramsACV").crewPositions = crewPositions
			
			addModifier("loadModel", require "addCameraPositions")
		end
	}
end