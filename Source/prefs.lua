class('Prefs').extends()

function Prefs:init()
	Prefs.super.init(self)
	
	self.prefsTable = playdate.datastore.read()
	
	if self.prefsTable == nil then
		self.prefsTable = {}
		playdate.datastore.write(self.prefsTable)
	end
end

function Prefs:get(key, default)
	log:print("Prefs GET for key: " .. key)
	log:printTable(self.prefsTable)
	local pref = self.prefsTable[key]
	if pref ~= nil then
		return pref
	else
		return default
	end
end

function Prefs:put(key, value)
	self.prefsTable[key] = value
	playdate.datastore.write(self.prefsTable)
	
	log:print("Prefs post PUT for key: " .. key)
	log:printTable(self.prefsTable)
end
