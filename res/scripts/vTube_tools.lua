------------------------------------------------------------------------------------
--	
------------------------------------------------------------------------------------
local function getValue(value, default)
	return (type(value) ~= type(default)) and default or value
end

------------------------------------------------------------------------------------
--	Prüft, ob "id" vom Typ "string" und nicht leer ("") ist.
------------------------------------------------------------------------------------
local function isValidId(id)
	return ((type(id) == "string") and (id ~= ""))
end

local vtTools = {
	getValue = getValue,
	isValidId = isValidId,
}

------------------------------------------------------------------------------------
--	Anlegen/Prüfen globaler Daten
------------------------------------------------------------------------------------
local function init()
	if (type(vacuumTubeGlobal) ~= "table") then
		vacuumTubeGlobal = {}
	end
	if (type(vacuumTubeGlobal.modParams) ~= "table") then
		vacuumTubeGlobal.modParams = {}
	end
end
init()

------------------------------------------------------------------------------------
--	Rückgabe globale Daten.
------------------------------------------------------------------------------------
vtTools.myGlobalData = function()
	return vacuumTubeGlobal
end

------------------------------------------------------------------------------------
--	Rückgabe der modParams.
--		Ist key leer ("") --> Rückgabe aller modParams; andernfalls Daten von key.
------------------------------------------------------------------------------------
vtTools.modParams = function(key)
	if isValidId(key) then
		if (type(vacuumTubeGlobal.modParams[key]) ~= "table") then
			vacuumTubeGlobal.modParams[key] = {}
		end
		return vacuumTubeGlobal.modParams[key]
	else
		return vacuumTubeGlobal.modParams
	end
end

------------------------------------------------------------------------------------
--	Speichert modParams des aktuellen Mods global ab.
--		Alle Werte werden auf Gültigkeit geprüft und um 1 erhöht.
--		Somit sind diese bereits fit für evtl. lua-Tabellenauswahl per Index. :)
------------------------------------------------------------------------------------
vtTools.saveModParams = function(modKey, modParams, defaulModParams)
	if (isValidId(modKey) and (type(modParams) == "table")) then
		local result = getValue(modParams[getCurrentModId()], {})
		for i, value in ipairs(getValue(defaulModParams, {})) do
			result[value.key] = getValue(result[value.key], getValue(value.defaultIndex, 0)) + 1
		end
		vacuumTubeGlobal.modParams[modKey] = result
	end
end

return vtTools