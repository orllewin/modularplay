import 'Coracle/string_utils'

class('AudioManager').extends()

local snd <const> = playdate.sound

function AudioManager:init()
	AudioManager.super.init(self)
	
	self.silentChannel = snd.channel.new()
	self.silentChannel:setVolume(0)
		
	self.channels = {}
end

function AudioManager:purge()
	for c=#self.channels, 1, -1 do
	local channel = self.channels[c]
	channel.channel:remove()
	table.remove(self.channels, m)
	end
end

function AudioManager:getSilentChannel()
	return self.silentChannel
end

function AudioManager:addChannel(modId, channel)
	print("Adding channel for mod: " .. modId)
	table.insert(self.channels, {
		modId = modId,
		channel = channel
	})
end

function AudioManager:getChannel(modId)
	if modId == nil then
		print("AudioManager:getChannel() Can't get channel for nil modId")
		return
	end
	for i=1,#self.channels do
		local channelRef = self.channels[i]
		print("modId: " .. modId .. " looking at channel: " .. channelRef.modId)
		if channelRef.modId == modId then
			return channelRef.channel
		end
	end
	
	return nil
end