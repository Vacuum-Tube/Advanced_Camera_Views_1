local tools = require "vTube_tools"
local camViews = require "AdvancedCameraViews"

local function addPositions (data, views)  -- add Camera view(s) to existing ones
	local function doInsert(source, dest)
		if source.transf then
			table.insert(dest, source)
		elseif (type(source) == "table") then
			for i, value in ipairs(source) do
				doInsert(value, dest)
			end
		end
	end
	----------------------------
	local options = tools.modParams("paramsACV")
	if ((options.replaceExistingViews == 1) or (type(data.metadata.cameraConfig) ~= "table") or (type(data.metadata.cameraConfig.positions) ~= "table")) then
		-- options.replaceExistingViews == 1	--> Vorhandene ersetzen
		data.metadata.cameraConfig = {positions = {}}
	end
	
	if (options.replaceExistingViews == 2) then
		-- options.replaceExistingViews == 2	--> Neue am Anfang platzieren
		local positions = {}
		doInsert({views, data.metadata.cameraConfig.positions}, positions)
		data.metadata.cameraConfig.positions = positions
	else
		-- options.replaceExistingViews == 3	--> Neue am Ende platzieren
		doInsert(views, data.metadata.cameraConfig.positions)
	end
end

local function createGroupsTable(data)
	local function handleGroup(result, params)
		local copyKeys = {
			"materials",
			"mesh",
			"name",
			"transf",
		}
		params.currentId = params.currentId + 1
		local myId = params.currentId
		local entry = {
			id = params.currentId,
			parentId = params.parentId,
			data = {},
		}
		for i, key in ipairs(copyKeys) do
			entry.data[key] = params.root[key]
		end
		result.childrenData[myId] = entry
		
		if (type(params.root.children) == "table") then
			for i, child in ipairs(params.root.children) do
				params.currentId = handleGroup(result, {
						root = child,
						currentId = params.currentId,
						parentId = myId,
					} )
			end
		end
		
		return params.currentId
	end
	--------------------------------------------------
	-- Hier geht's los :)
	--------------------------------------------------
	local result = {
		childrenData = {},
		deactivatableIds = {},
	}
	
	if ((type(data.lods) == "table") and (type(data.lods[1]) == "table") and (type(data.lods[1].node) == "table")) then
		--	Group- and mesh handling
		handleGroup(result, {
				root = data.lods[1].node,
				currentId = -1,
				parentId = -1,
			} )
			
		--	Handling deactivatable groups
		if ((type(data.metadata.railVehicle) == "table") and (type(data.metadata.railVehicle.configs) == "table") and
			(type(data.metadata.railVehicle.configs[1]) == "table")) then
			
			local deactivatableKeys = {
				"backBackwardParts",
				"backForwardParts",
				"frontBackwardParts",
				"frontForwardParts",
				"innerBackwardParts",
				"innerForwardParts"
			}
			
			for i, deactivatableKey in ipairs(deactivatableKeys) do
				for j, id in ipairs(tools.getValue(data.metadata.railVehicle.configs[1][deactivatableKey], {})) do
					result.deactivatableIds[id] = true
				end
			end
		end
	end
	
	return result
end

local function isValidBoundingInfo(boundingInfo)
	-- Sicherstellen, dass "boundingInfo" valid ist und das Modell 3-dimensionale Ausmaße hat.
	if ((type(boundingInfo) == "table") and (type(boundingInfo.bbMax) == "table") and (type(boundingInfo.bbMin) == "table")) then
		if ((boundingInfo.bbMax[1] - boundingInfo.bbMin[1] > 0) and (boundingInfo.bbMax[2] - boundingInfo.bbMin[2] > 0) and
			(boundingInfo.bbMax[3] - boundingInfo.bbMin[3] > 0)) then
			return true
		end
	end
	return false
end


local invalidModels = {
	["res/models/model/vehicle/tram/usa/skoda_10t.mdl"] = true,  -- immediate freeze when adding camera views, unknown reason
}

-- addModifier "loadModel"
return function (fileName, data)
	if invalidModels[fileName] then
		return data
	end
	
	if data and data.metadata and isValidBoundingInfo(data.boundingInfo) then
		local options = tools.modParams("paramsACV")
		local viewsParams = {
			fileName = fileName,
			data = data,
			groupsTable = createGroupsTable(data),
		}
		
		local xmax=data.boundingInfo.bbMax[1]
		local ymax=data.boundingInfo.bbMax[2]
		local zmax=data.boundingInfo.bbMax[3]
		local xmin=data.boundingInfo.bbMin[1]
		local ymin=data.boundingInfo.bbMin[2]
		local zmin=data.boundingInfo.bbMin[3]
		
		if data.metadata.transportVehicle then
			if data.metadata.transportVehicle.carrier=="RAIL" and data.metadata.railVehicle then  -- Rail vehicle
				if data.metadata.railVehicle.engines and #data.metadata.railVehicle.engines>0 then
					addPositions(data, camViews.TrainViews(xmax,ymax,zmax,xmin,ymin,zmin,viewsParams)) -- Traction unit
				else
					addPositions(data, camViews.WaggonViews(xmax,ymax,zmax,xmin,ymin,zmin,viewsParams))  -- Waggon
				end
			end
			if data.metadata.transportVehicle.carrier=="TRAM" and data.metadata.railVehicle then  -- Tram vehicle
				if data.metadata.railVehicle.engines then
					addPositions(data, camViews.TramViews(xmax,ymax,zmax,xmin,ymin,zmin,viewsParams))
				else
					
				end
			end
			if data.metadata.transportVehicle.carrier=="ROAD" and data.metadata.roadVehicle then  -- Road vehicle
				addPositions(data, camViews.RoadViews(xmax,ymax,zmax,xmin,ymin,zmin,viewsParams))
			end
			if data.metadata.waterVehicle then  -- Ship
				addPositions(data, camViews.ShipViews(xmax,ymax,zmax,xmin,ymin,zmin,viewsParams))
			end
			if data.metadata.airVehicle then  -- Airplane
				addPositions(data, camViews.PlaneViews(xmax,ymax,zmax,xmin,ymin,zmin,viewsParams))
			end
		end
		if data.metadata.car then  -- Car
			addPositions(data, camViews.CarViews(xmax,ymax,zmax,xmin,ymin,zmin,viewsParams))
		end
		if (data.metadata.person and (options.addPersonViews == 1)) then  -- Person
			addPositions(data, camViews.PersonViews(xmax,ymax,zmax,xmin,ymin,zmin,viewsParams))
		end
		if data.metadata.animal then  -- Animal
			addPositions(data, camViews.AnimalViews(xmax,ymax,zmax,xmin,ymin,zmin,viewsParams))
		end
		-- data.metadata.cameraConfig = {positions = { {} }} -- try this for fun
	end
	return data
end