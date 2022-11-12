function data()
return {
	en = {
		["name"] = "Advanced Camera Views",
		["desc"] = "Adds different Camera Views to Trains, Trams, Busses, Trucks, Cars, Ships, Planes, Persons and Animals",
		
		["replaceExistingViewsNAME"] = "Camera positions",
		["replaceExistingViewsTT"] = "Behavior when adding the new camera positions",
		
		["addCrewSeatsNAME"] = "Add driver perspectives",
		["addCrewSeatsTT"] = "Include driver seat views",
		
		["posCrewSeatsNAME"] = "Camera position to the driver",
		["posCrewSeatsTT"] = "Select the position of the camera to the driver.\n"..
			"Negative values place the camera more behind the driver; positive ones in front of the driver.\n"..
			"Indications in meters.",
		
		["addPassengerSeatsNAME"] = "Add passenger perspectives",
		["addPassengerSeatsTT"] = "Include one passenger seat view (first forward sitting)",

		["addPersonViewsNAME"] = "Add people perspectives",
		["addPersonViewsTT"] = "Adds views to persons \n(WARNING: Can freeze if you enter an airport/underground station where persons get teleported)",
	},
	de = {
		--["name"] = "Erweiterte Kamera-Perspektiven",
		["desc"] = "Fügt verschiedene Kamera-Perspektiven bei Zügen, Straßenbahnen, Bussen, Lastwagen, Autos, Schiffen, Flugzeugen, Personen und Tieren hinzu",
		
		["replaceExistingViewsNAME"] = "Kamerapositionen",
		["replaceExistingViewsTT"] = "Verhalten beim Hinzufügen der neuen Kamerapositionen",
		["Replace existing"] = "Vorhandene ersetzen";
		["Place new at the beginning"] = "Neue am Anfang platzieren";
		["Place new at the end"] = "Neue am Ende platzieren";
		
		["addCrewSeatsNAME"] = "Fahrer Perspektiven hinzufügen",
		["addCrewSeatsTT"] = "Ansicht vom Fahrersitzplatz hinzufügen",
		
		["posCrewSeatsNAME"] = "Kameraposition zum Fahrer",
		["posCrewSeatsTT"] = "Wähle die Position der Kamera zum Fahrer.\n"..
			"Negative Werte platzieren die Kamera mehr hinter dem Fahrer; Positive vor dem Fahrer.\n"..
			"Angaben in Meter.",
		
		["addPassengerSeatsNAME"] = "Passagier Perspektiven hinzufügen",
		["addPassengerSeatsTT"] = "Fügt Perspektive von einem Passagierplatz hinzu (erster vorwärts sitzender)",

		["addPersonViewsNAME"] = "Personen Perspektiven hinzufügen",
		["addPersonViewsTT"] = "Fügt Ansichten zu Personen hinzu \n(WARNUNG: Kann Freeze verursachen, wenn Personen in einen Flughafen/U-Station gehen, wo Personen teleportiert werden)",
	}
}
end