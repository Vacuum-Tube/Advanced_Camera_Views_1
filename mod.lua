local modUtil = require "merk_modutil_1"
local addCameraPositions = require "addCameraPositions"

local optionsACV = {
	addCrewSeats = {
		type = "boolean", 
		default = true,
		name = _("Add Crew Seats"),
		description = _("addCrewSeats"),
	},
	addPassengerSeats = {
		type = "boolean",
		default = true,
		name = _("Add Passenger Seats"),
		description = _("addPassengerSeats"),
	},
}

function data()
	return {
		info = {
			name = _("name"),
			description = _("desc"),
			minorVersion = 3,
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
		},
		settings = optionsACV,
		runFn = function (settings)
			modUtil.userSettings.create("Advanced_Camera_Views_1", optionsACV)
			addModifier("loadModel", addCameraPositions)
		end
	}
end