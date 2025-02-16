class('Logger').extends()

function Logger:init()
	Logger.super.init(self)
end

function Logger:print(message)
	if playdate.isSimulator == 1 then
		print(message)
	end
end

function Logger:printTable(table)
	if playdate.isSimulator == 1 then
		printTable(table)
	end
end

