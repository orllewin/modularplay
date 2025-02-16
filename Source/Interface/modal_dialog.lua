class('ModalDialog').extends(playdate.graphics.sprite)

local gfx <const> = playdate.graphics

function ModalDialog:init(message, cancelStr, confirmStr)
	ModalDialog.super.init(self)
	
	local cancel = "(B) Cancel"
	if cancelStr ~= nil then
		cancel = cancelStr
	end
	
	local confirm = "(A) Confirm"
	if confirmStr ~= nil then
		confirm = confirmStr
	end
	
	local messageImage = gfx.imageWithText(message .. " " .. cancel .. ", " .. confirm, 400, 100)
	local width, height = messageImage:getSize()
	self:setImage(messageImage)
	self:moveTo((width/2) + 5, 240 - (height))
	self:setIgnoresDrawOffset(true)
end

function ModalDialog:show(onDismiss)
	self.onDismiss = onDismiss
	self:add()
	
	self.inputHandler = {
		BButtonDown = function()
			self:remove()
			playdate.inputHandlers.pop()
			if self.onDismiss ~= nil then self.onDismiss(false) end
			
		end,
		
		AButtonDown = function()
			self:remove()
			playdate.inputHandlers.pop()
			if self.onDismiss ~= nil then self.onDismiss(true) end
		end
	}
	
	playdate.inputHandlers.push(self.inputHandler)
end