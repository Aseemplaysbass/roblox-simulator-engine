local Settings = {}

export type Setting = 
				"Click Sound " |
				"Music" |
				"Show my Pets" |
				"Show Other Pets" |
				"Show Click Popup" |
				"Character Effects" |
				"Button Effects" |
				"Random Gifts" |
				"Show Update Timer" |
				"AFK Hatching" |
				"Global Messages" |
				"Auto Ascension" |
				"Skip Hatch Animation" |
				"Auto Pet Merge"

Settings.Settings = {
	"Click Sound " ,
	"Music" ,
	"Show my Pets" ,
	"Show Other Pets" ,
	"Show Click Popup" ,
	"Character Effects" ,
	"Button Effects" ,
	"Random Gifts" ,
	"Show Update Timer" ,
	"AFK Hatching" ,
	"Global Messages" ,
	"Auto Ascension" ,
	"Skip Hatch Animation" ,
	"Auto Pet Merge"
}

function Settings.IsSettingActive(setting: Setting, data)
	return data.Settings[setting]
end

return Settings