local merkVehicleUtil
local merkSettingsUtil
local version = 1
local minorVersion = 0

require "stringutil"

-- base functions
local function fileExists(fileName)
	local file = io.open(fileName, "r")
	if file then
		file:close()
		return true
	end
	return false
end

local function table_equal(t1, t2)
	if type(t1) ~= "table" or type(t2) ~= "table" then
		return false
	end
	local isEqual = true
	local checkedKeys = {}
	for k, v in pairs(t1) do
		if (t2[k] == nil) or (type(t2[k]) ~= type(v)) then
			isEqual = false
			break
		elseif type(v) == "table" then
			isEqual = table_equal(v, t2[k])
			if not isEqual then
				break
			end
		elseif v ~= t2[k] then
			isEqual = false
			break
		end
		checkedKeys[k] = true
	end
	if isEqual then
		for k, v in pairs(t2) do
			if not checkedKeys[k] then
				if (t1[k] == nil) or (type(t1[k]) ~= type(v)) then
					isEqual = false
					break
				elseif type(v) == "table" then
					isEqual = table_equal(v, t1[k])
					if not isEqual then
						break
					end
				elseif v ~= t1[k] then
					isEqual = false
					break
				end
			end
		end
	end
	return isEqual
end

-- Repaints
local function addMaterial(id, file, materials)
	if type(merkVehicleUtil) == "table" and type(merkVehicleUtil[id]) == "table" and type(materials) == "table" then
		if type(merkVehicleUtil[id].meshData) == "table" and merkVehicleUtil[id].meshData[file] then
			local mesh = merkVehicleUtil[id].meshData[file]
			local matConfig = {}
			if type(mesh.materials) == "table" then
				for i, subMesh in ipairs(mesh.materials) do
					local matConf = 0
					for k, material in ipairs(materials) do
						if type(subMesh) == "table" and type(material) == "table" and material[1] and material[2] then
							for j, mat in ipairs(subMesh) do
								if mat == material[1] and mat ~= material[2] then
									subMesh[#subMesh+1] = material[2]
									matConf = #subMesh-1
								end
								if mat == material[2] and (j < #subMesh or matConf == 0) then
									-- material already exists
									if matConf > 0 then
										subMesh[#subMesh] = nil
										matConf = j-1
									end
									break
								end
							end
						end
					end
					matConfig[#matConfig+1] = matConf
				end
			end
			
			local matConfigId = #mesh.matConfigs+1
			if type(mesh.matConfigs) == "table" and #matConfig > 0 then
				for i, matConf in ipairs(mesh.matConfigs) do
					if table_equal(matConf, matConfig) then
						matConfigId = i
						break
					end
				end
				if matConfigId > #mesh.matConfigs then
					mesh.matConfigs[matConfigId] = matConfig
				end
				return matConfigId-1
			end
		end
	end
	return nil
end

local function getGroupMatConfig(id, file, matConfigs)
	if type(merkVehicleUtil) == "table" and type(merkVehicleUtil[id]) == "table" then
		if type(merkVehicleUtil[id].groupData) == "table" and merkVehicleUtil[id].groupData[file] then
			local group = merkVehicleUtil[id].groupData[file]
			local matConfig = {}
			
			if type(group.meshes) == "table" and type(matConfigs) == "table" then
				for i, mesh in ipairs(group.meshes) do
					if matConfigs[mesh] then
						matConfig[#matConfig+1] = matConfigs[mesh]
					else
						matConfig[#matConfig+1] = 0
					end
				end
				
				if type(group.matConfigs) == "table" then
					local matConfigID = #group.matConfigs+1
					for i, matConf in ipairs(group.matConfigs) do
						if table_equal(matConf, matConfig) then
							matConfigID = i
							break
						end
					end
					if matConfigID > #group.matConfigs then
						group.matConfigs[matConfigID] = matConfig
					end
					return matConfigID-1
				end
			end
		end
	end
	return nil
end

local function addRepaint(id, repaintId, materials, files)
	if type(merkVehicleUtil) == "table" then
		if type(merkVehicleUtil[id]) == "table" and merkVehicleUtil[id].created then
			-- make sure "meshData" and "groupData" are tables
			local meshData = {}
			if type(merkVehicleUtil[id].meshData) == "table" then
				meshData = merkVehicleUtil[id].meshData
			end
			local groupData = {}
			if type(merkVehicleUtil[id].groupData) == "table" then
				groupData = merkVehicleUtil[id].groupData
			end
			
			local meshFiles = {}
			local groupFiles = {}
			if type(files) == "table" and #files > 0 then
				for i, file in ipairs(files) do
					if meshData[file] then
						meshFiles[#meshFiles+1] = file
					elseif groupData[file] then
						groupFiles[#groupFiles+1] = file
					end
				end
			else
				for file, data in pairs(meshData) do
					meshFiles[#meshFiles+1] = file
				end
				for file, data in pairs(groupData) do
					groupFiles[#groupFiles+1] = file
				end
			end
			
			local matConfigs = {}
			for i, file in ipairs(meshFiles) do
				matConfigs[file] = addMaterial(id, file, materials)
			end
			
			for i, file in ipairs(groupFiles) do
				matConfigs[file] = getGroupMatConfig(id, file, matConfigs)
			end
			
			if type(merkVehicleUtil[id].repaints) ~= "table" then
				merkVehicleUtil[id].repaints = {}
			end
			
			merkVehicleUtil[id].repaints[repaintId] = matConfigs
		else
			-- main mod not loaded, store data for later use
			if type(merkVehicleUtil[id]) ~= "table" then
				merkVehicleUtil[id] = {}
			end
			if type(merkVehicleUtil[id].pendingRepaints) ~= "table" then
				merkVehicleUtil[id].pendingRepaints = {}
			end
			merkVehicleUtil[id].pendingRepaints[#merkVehicleUtil[id].pendingRepaints+1] = {
				id = repaintId,
				materials = materials,
				files = files
			}
		end
	end
end

local function getRepaint(id, repaintId, data)
	if type(merkVehicleUtil) == "table" and type(merkVehicleUtil[id]) == "table" and type(merkVehicleUtil[id].repaints) == "table" then
		if type(merkVehicleUtil[id].repaints[repaintId]) == "table" then
			local matConfigs = merkVehicleUtil[id].repaints[repaintId]
		
			if type(data) == "table" and type(data.lods) == "table" then
				for i, lod in ipairs(data.lods) do
					local matConfig = {}
					if type(lod) == "table" then
						for j, child in ipairs(lod.children) do
							if matConfigs[child.id] then
								matConfig[#matConfig+1] = matConfigs[child.id]
							elseif lod.matConfigs[1][j] then
								matConfig[#matConfig+1] = lod.matConfigs[1][j]
							else
								matConfig[#matConfig+1] = 0
							end
						end
					else
						print("[ModUtil] Missing key \"lod.children\".")
					end
					lod.matConfigs[1] = matConfig
				end
			end
	
			return matConfigs
		end
	end
	if type(data) == "table" then
		data.metadata = {}
	end
	
	return {}
end

local function getMeshData(id, fileName, data)
	if type(merkVehicleUtil) == "table" and type(merkVehicleUtil[id]) == "table" and type(merkVehicleUtil[id].meshData) == "table" then
		local meshData = merkVehicleUtil[id].meshData[fileName]
		
		if type(meshData) == "table" and data then
			if meshData.matConfigs then
				data.matConfigs = meshData.matConfigs
			end
			if type(meshData.materials) == "table" and type(data.subMeshes) == "table" then
				for i, subMesh in ipairs(data.subMeshes) do
					if meshData.materials[i] then
						subMesh.materials = meshData.materials[i]
					end
				end
			end
		end
		
		return meshData
	end
end

local function getGroupData(id, fileName, data)
	if type(merkVehicleUtil) == "table" and type(merkVehicleUtil[id]) == "table" and type(merkVehicleUtil[id].groupData) == "table" then
		local groupData = merkVehicleUtil[id].groupData[fileName]
		
		if type(groupData) == "table" and data then
			if groupData.matConfigs then
				data.matConfigs = groupData.matConfigs
			end
		end
		
		return groupData
	end
end

local function setMetadata(id, fileName, metadata, priority)
	if type(merkVehicleUtil) == "table" then
		if type(merkVehicleUtil[id]) ~= "table" then
			merkVehicleUtil[id] = {}
		end		
		
		local prio = priority or 0
		if type(merkVehicleUtil[id].metadata) ~= "table" then
			merkVehicleUtil[id].metadata = {}
		end
		if type(merkVehicleUtil[id].metadata[fileName]) ~= "table" then
			merkVehicleUtil[id].metadata[fileName] = {}
		end
		
		metadataCache = merkVehicleUtil[id].metadata[fileName]
		
		if type(metadata) == "table" then
			for key, value in pairs(metadata) do
				if metadataCache[key] == nil or (type(metadataCache[key]) == "table" and metadataCache[key].priority < prio) then
					metadataCache[key] = {
						value = value,
						priority = prio
					}
				end
			end
		end
	end
end

local function changeMetadata(id, fileName, data)
	if type(merkVehicleUtil) == "table" and type(merkVehicleUtil[id]) == "table" then
		local metadata = {}
		if type(merkVehicleUtil[id].metadata) == "table" and type(merkVehicleUtil[id].metadata[fileName]) == "table" then
			metadata = merkVehicleUtil[id].metadata[fileName]
		end
		
		if type(data) == "table" and type(data.metadata) == "table" then
			for key, value in pairs(metadata) do
				data.metadata[key] = value.value
			end
		end
	end
end

local function readFiles(files, options)
	local meshData = {}
	local groupData = {}
	local dataBackup = data
	
	local info
	local i = 1
	repeat
		info = debug.getinfo(i,'S')
		i = i+1
	until info == nil
	info = debug.getinfo(i-2,'S')
	
	local modPath
	if string.ends(info.source, 'mod.lua') then
		modPath = string.gsub(info.source, "@(.*/)mod[.]lua", "%1")
	elseif string.ends(info.source, '.mdl') then
		modPath = string.gsub(info.source, "@(.*/)res/models/model/.+[.]mdl", "%1")
	end
	
	if fileExists(modPath.."mod.lua") then
		local repaintFileName = modPath.."repaintFiles.lua"
		if type(options) ~= "table" or (options.useRepaintFile ~= false and options.devMode ~= true) then
			local repaintFile = loadfile(repaintFileName)
			if repaintFile then
				return repaintFile()
			end
		end
		
		if type(options) == "table" and (options.loadMeshes or (options.loadMeshes == nil and options.devMode)) then
			for i, file in ipairs(files) do
				if type(file) == "string" then
					if string.ends(file, ".msh") then
						local meshFile = loadfile(modPath.."res/models/mesh/"..file)
						if meshFile then
							meshFile()
						end
						if meshFile and type(data) == "function" then
							local mesh = data()
							local mData
							
							if type(mesh) == "table" and mesh.matConfigs and mesh.subMeshes then
								mData = {
									materials = {},
								}
								mData.matConfigs = mesh.matConfigs
								for j, subMesh in ipairs(mesh.subMeshes) do
									if subMesh.materials then
										mData.materials[#mData.materials+1] = subMesh.materials
									else
										print(string.format("[VehicleUtil] Missing field \"submesh.material\" in mesh %q!"), file)
									end
								end
							end
							
							meshData[file] = mData
						end
					elseif string.ends(file, ".grp") then
						local groupFile = loadfile(modPath.."res/models/group/"..file)
						if groupFile then
							groupFile()
						end
						if groupFile and type(data) == "function" then
							local group = data()
							local gData
							
							if type(group) == "table" and group.matConfigs and group.children then
								gData = {
									meshes = {},
								}
								gData.matConfigs = group.matConfigs
								for j, child in ipairs(group.children) do
									if child.id then
										gData.meshes[#gData.meshes+1] = child.id
									else
										print(string.format("[VehicleUtil] Missing field \"child.id\" in group %q!"), file)
									end
								end
							end
							
							groupData[file] = gData
						end
					end
				end
			end
			
			data = dataBackup
			
			if options.createRepaintFile or (options.createRepaintFile == nil and options.devMode) then
				local repaintFile = io.open(repaintFileName, "w")
				if repaintFile then
					require "serialize"
					repaintFile:write("local "..serializeStr({ meshData = meshData, groupData = groupData }))
					repaintFile:write("local result = data()\nreturn result.meshData, result.groupData")
					repaintFile:close()
				else
					print("[ModUtil] Creation of repaint file failed")
				end
			end
		end
	else
		print("[ModUtil] Could not read files. Maybe the function was called from a wrong file.")
	end
	
	return meshData, groupData
end

local function createEnvironment(id, files, meshes, groups, options, modelViewer)
	local meshData = {}
	local groupData = {}
	if type(files) == "table" and #files > 0 then
		meshData, groupData = readFiles(files, options)
	else
		meshData = meshes
		groupData = groups
	end
	
	if game or modelViewer then
		if modelViewer then
			if merkVehicleUtil == nil then
				merkVehicleUtil = {}
			end
		else
			if type(game.merkVehicleUtil) ~= "table" then
				game.merkVehicleUtil = {}
			end
			if type(game.merkVehicleUtil[version]) ~= "table" then
				game.merkVehicleUtil[version] = {}
			end
			merkVehicleUtil = game.merkVehicleUtil[version]
		end
		
		if type(merkVehicleUtil[id]) == "table" and merkVehicleUtil[id].created then
			print(string.format("[ModUtil] Creation of repaint environment for id %q failed, the id is already registered.", id))
		else
			if type(merkVehicleUtil[id]) ~= "table" then
				merkVehicleUtil[id] = {}
			end
			
			merkVehicleUtil[id].created = true
			
			merkVehicleUtil[id].meshData = meshData
			merkVehicleUtil[id].groupData = groupData
			
			if type(merkVehicleUtil[id].pendingRepaints) == "table" and #merkVehicleUtil[id].pendingRepaints > 0 then
				pendingRepaints = merkVehicleUtil[id].pendingRepaints
				merkVehicleUtil[id].pendingRepaints = nil
				for i, repaint in ipairs(pendingRepaints) do
					addRepaint(id, repaint.id, repaint.materials, repaint.files)
				end
			end
			
			return {
				addRepaint = function(repaintId, materials, files)
					return addRepaint(id, repaintId, materials, files)
				end,
				getRepaint = function(repaintId, data)
					return getRepaint(id, repaintId, data)
				end,
				getMeshData = function(fileName)
					return getMeshData(id, fileName)
				end,
				getGroupData = function(fileName)
					return getGroupData(id, fileName)
				end,
				setMetadata = function(fileName, metadata, priority)
					return setMetadata(id, fileName, metadata, priority)
				end,
				changeMetadata = function(fileName, data)
					return changeMetadata(id, fileName, data)
				end,
			}
		end
	else
		print(string.format("[ModUtil] Creation of repaint environment for id %q failed. It seems you're trying to create the environment outside the \"runFn\".", id))
	end
end

local function modelViewerRepaint(id, repaintId, materials, files, data)
	createEnvironment(id, {""}, nil, nil, nil, true, 4)
	addRepaint(id, repaintId, materials, files)
	getRepaint(id, repaintId, data)
end

if not merk_vehicleUtil or not merk_vehicleUtil[version] then
	if game then
		if type(game.merkVehicleUtil) ~= "table" then
			game.merkVehicleUtil = {}
		end
		if type(game.merkVehicleUtil[version]) ~= "table" then
			game.merkVehicleUtil[version] = {}
		end
		merkVehicleUtil = game.merkVehicleUtil[version]
	end

	if type(merk_vehicleUtil) ~= "table" then
		merk_vehicleUtil = {}
	end

	merk_vehicleUtil[version] = {
		createEnvironment = createEnvironment,
		addRepaint = addRepaint,
		getRepaint = getRepaint,
		getMeshData = getMeshData,
		getGroupData = getGroupData,
		modelViewerRepaint = modelViewerRepaint,
		setMetadata = setMetadata,
		changeMetadata = changeMetadata,
		minorVersion = minorVersion,
	}
else
	if merk_vehicleUtil[version].minorVersion < minorVersion then
		merk_vehicleUtil[version] = {
			createEnvironment = createEnvironment,
			addRepaint = addRepaint,
			getRepaint = getRepaint,
			getMeshData = getMeshData,
			getGroupData = getGroupData,
			modelViewerRepaint = modelViewerRepaint,
			setMetadata = setMetadata,
			changeMetadata = changeMetadata,
			minorVersion = minorVersion,
		}
	end
end

-- settings
local function readUserSettings(id)	
	if type(merkSettingsUtil) == "table" and type(merkSettingsUtil[id]) == "table" then
		local settings = merkSettingsUtil[id].values
		
		local info
		local i = 1
		repeat
			info = debug.getinfo(i,'S')
			i = i+1
		until info == nil
		info = debug.getinfo(i-2,'S')
		
		local modPath
		if string.ends(info.source, 'mod.lua') then
			modPath = string.gsub(info.source, "@(.*/)mod[.]lua", "%1")
		elseif string.ends(info.source, '.mdl') then
			modPath = string.gsub(info.source, "@(.*/)res/models/model/.+[.]mdl", "%1")
		end
		
		if fileExists(modPath.."mod.lua") then
			local settingsFile = loadfile(modPath.."settings.lua")
			local loadedSettings = {}
			
			if settingsFile then
				loadedSettings = settingsFile()
			end
			
			if type(loadedSettings) == "table" then
				for option_key, option in pairs(merkSettingsUtil[id].definitions) do
					if type(loadedSettings[option_key]) == option.type then
						local value = loadedSettings[option_key]
						if option.type == "number" then
							if option.min and value < option.min then
								value = option.min
							end
							if option.max and value > option.max then
								value = option.max
							end
						end
						settings[option_key] = value
					end
				end
			end
		end
	end
end

local function createUserSettings(id, options)
	
	if type(merkSettingsUtil) == "table" then
		if merkSettingsUtil[id] then
			print(string.format("[ModUtil] Previous settings for id %q are overwritten.", id))
		end
		
		merkSettingsUtil[id] = {
			definitions = options,
			values = {},
		}
		
		for option_key, option in pairs(options) do
			if option.type and option.name then
				if option.default ~= nil then
					merkSettingsUtil[id].values[option_key] = option.default
				else
					if option.type == "boolean" then
						merkSettingsUtil[id].values[option_key] = false
					elseif option.type == "number" then
						merkSettingsUtil[id].values[option_key] = 0
					elseif option.type == "string" then
						merkSettingsUtil[id].values[option_key] = ""
					end
				end
			end
		end
		
		readUserSettings(id)
	end
end

local function getUserSettings(id)
	local settings = {}
	
	if type(merkSettingsUtil) == "table" and type(merkSettingsUtil[id]) == "table" then
		settings = merkSettingsUtil[id].values
	end
	
	return settings
end

if not merk_SettingsUtil or not merk_SettingsUtil[version] then
	if game then
		if type(game.merkSettingsUtil) ~= "table" then
			game.merkSettingsUtil = {}
		end
		if type(game.merkSettingsUtil[version]) ~= "table" then
			game.merkSettingsUtil[version] = {}
		end
		merkSettingsUtil = game.merkSettingsUtil[version]
	end

	if type(merk_SettingsUtil) ~= "table" then
		merk_SettingsUtil = {}
	end

	merk_SettingsUtil[version] = {
		create = createUserSettings,
		get = getUserSettings,
		minorVersion = minorVersion,
	}
else
	if merk_SettingsUtil[version].minorVersion < minorVersion then
		merk_SettingsUtil[version] = {
			create = createUserSettings,
			get = getUserSettings,
			minorVersion = minorVersion,
		}
	end
end

local mod_util = {
	vehicles = merk_vehicleUtil[version],
	userSettings = merk_SettingsUtil[version],
	initialize = function (id, settings, files, meshes, groups, options, modelViewer)
			merk_SettingsUtil[version].create(id, settings)
			return merk_vehicleUtil[version].createEnvironment(id, files, meshes, groups, options, modelViewer)
		end,
	minorVersion = minorVersion,
}

if not merk_modutil or not merk_modutil[version] then
	if type(merk_modutil) ~= "table" then
		merk_modutil = {}
	end
	merk_modutil[version] = mod_util
else
	if merk_modutil[version].minorVersion < minorVersion then
		merk_modutil[version] = mod_util
	end
end

return merk_modutil[version]
