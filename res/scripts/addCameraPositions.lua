local camViews = require "AdvancedCameraViews"

function addPositions (data, views)  -- add Camera view(s) to existing ones
	if type(data.metadata.cameraConfig) ~= "table" then
		data.metadata.cameraConfig = {positions = {}}
	end
	if views.transf then
		table.insert(data.metadata.cameraConfig.positions, views)
	else
		for _,cameraView in pairs(views) do
			if cameraView.transf then
				table.insert(data.metadata.cameraConfig.positions, cameraView)
			else
				for _,cameraView2 in pairs(cameraView) do
					table.insert(data.metadata.cameraConfig.positions, cameraView2)
				end
			end
		end
	end
end

-- addModifier "loadModel"
return function (filename, data)
	if data and data.metadata and data.boundingInfo and data.boundingInfo.bbMax and data.boundingInfo.bbMin then
		local xmax=data.boundingInfo.bbMax[1]
		local ymax=data.boundingInfo.bbMax[2]
		local zmax=data.boundingInfo.bbMax[3]
		local xmin=data.boundingInfo.bbMin[1]
		local ymin=data.boundingInfo.bbMin[2]
		local zmin=data.boundingInfo.bbMin[3]
		
		if data.metadata.transportVehicle then
			if data.metadata.transportVehicle.carrier=="RAIL" and data.metadata.railVehicle then  -- Rail vehicle
				if data.metadata.railVehicle.engines and #data.metadata.railVehicle.engines>0 then
					addPositions(data, camViews.TrainViews(xmax,ymax,zmax,xmin,ymin,zmin,data)) -- Traction unit
				else
					addPositions(data, camViews.WaggonViews(xmax,ymax,zmax,xmin,ymin,zmin,data))  -- Waggon
				end
			end
			if data.metadata.transportVehicle.carrier=="TRAM" and data.metadata.railVehicle then  -- Tram vehicle
				if data.metadata.railVehicle.engines then
					addPositions(data, camViews.TramViews(xmax,ymax,zmax,xmin,ymin,zmin,data))
					--commonapi.dmp({filename=filename,data.metadata.cameraConfig}) -- issue with skoda_10t
				else
					
				end
			end
			if data.metadata.transportVehicle.carrier=="ROAD" and data.metadata.roadVehicle then  -- Road vehicle
				addPositions(data, camViews.RoadViews(xmax,ymax,zmax,xmin,ymin,zmin,data))
			end
			if data.metadata.waterVehicle then  -- Ship
				addPositions(data, camViews.ShipViews(xmax,ymax,zmax,xmin,ymin,zmin,data))
			end
			if data.metadata.airVehicle then  -- Airplane
				addPositions(data, camViews.PlaneViews(xmax,ymax,zmax,xmin,ymin,zmin,data))
			end
		end
		if data.metadata.car then  -- Car
			addPositions(data, camViews.CarViews(xmax,ymax,zmax,xmin,ymin,zmin,data))
		end
		if data.metadata.person then  -- Person
			addPositions(data, camViews.PersonViews(xmax,ymax,zmax,xmin,ymin,zmin,data))
		end
		if data.metadata.animal then  -- Animal
			addPositions(data, camViews.AnimalViews(xmax,ymax,zmax,xmin,ymin,zmin,data))
		end
		-- data.metadata.cameraConfig = {positions = { {} }} -- try this for fun
	end
	return data
end