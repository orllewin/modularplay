--[[
	© 2023 Orllewin - All Rights Reserved.
]]

function buildGhostModule(w, h)
	local gfx <const> = playdate.graphics
	local templateImage = gfx.image.new(w, h)
	gfx.pushContext(templateImage)
	gfx.setLineWidth(6)
	gfx.setColor(gfx.kColorBlack)
	gfx.drawRoundRect(3, 3, w-6, h-6, 8)
	gfx.setLineWidth(1)
	gfx.popContext()
	
	local ghostImage = gfx.image.new(w, h)
	gfx.pushContext(ghostImage)
	templateImage:drawFaded(0, 0, 0.3, gfx.image.kDitherTypeDiagonalLine)
	gfx.popContext()
	
	return gfx.sprite.new(ghostImage)
end

function getModName(type)
	local modList = getMenuModList()
	for c=1,#modList do
		local mods = modList[c].mods
		for m=1,#mods do
			local mod = mods[m]
			if mod.type == type then
				return mod.label
			end
		end
	end
end



function generateModBackground(w, h)
	local gfx <const> = playdate.graphics
	local backgroundImage = gfx.image.new(w, h)
	gfx.pushContext(backgroundImage)
	gfx.setLineWidth(1)
	playdate.graphics.setColor(playdate.graphics.kColorWhite)
	gfx.fillRoundRect(1, 1, w-2, h-2, gCornerRad)
	playdate.graphics.setColor(playdate.graphics.kColorBlack)
	gfx.drawRoundRect(1, 1, w-2, h-2, gCornerRad)	
	gfx.popContext()
	
	return backgroundImage
end

function generateHalftoneRoundedRect(w, h, o)
	local gfx <const> = playdate.graphics
	local blackImage = gfx.image.new(w, h)
	gfx.pushContext(blackImage)
		playdate.graphics.setColor(playdate.graphics.kColorBlack)
		gfx.fillRoundRect(1, 1, w, h, gCornerRad)
	gfx.popContext()
	
	local halftoneImage = gfx.image.new(w, h)
	gfx.pushContext(halftoneImage)
	blackImage:drawFaded(1, 1, o, playdate.graphics.image.kDitherTypeDiagonalLine)
	gfx.popContext()
	
	return halftoneImage
end

function generateModBackgroundNoBorder(w, h)
	local gfx <const> = playdate.graphics
	local backgroundImage = gfx.image.new(w, h)
	gfx.pushContext(backgroundImage)
	playdate.graphics.setColor(playdate.graphics.kColorWhite)
	gfx.fillRoundRect(1, 1, w-2, h-2, gCornerRad)
	gfx.setLineWidth(1)
	gfx.popContext()
	
	return backgroundImage
end

function generateModBackgroundBold(w, h)
	local gfx <const> = playdate.graphics
	local backgroundImage = gfx.image.new(w, h)
	gfx.pushContext(backgroundImage)
	gfx.setLineWidth(2)
	playdate.graphics.setColor(playdate.graphics.kColorWhite)
	gfx.fillRoundRect(1, 1, w-2, h-2, gCornerRad)
	playdate.graphics.setColor(playdate.graphics.kColorBlack)
	gfx.drawRoundRect(1, 1, w-2, h-2, gCornerRad)	
	gfx.setLineWidth(1)
	gfx.popContext()
	
	return backgroundImage
end

function generateButtonModBackground(w, h)
	local gfx <const> = playdate.graphics
	local backgroundImage = gfx.image.new(w + 6, h + 6)
	gfx.pushContext(backgroundImage)
	gfx.setLineWidth(1)
	playdate.graphics.setColor(playdate.graphics.kColorWhite)
	gfx.fillRoundRect(1, 1, w + 6 -2, h + 6 -2, gCornerRad)
	playdate.graphics.setColor(playdate.graphics.kColorBlack)
	gfx.drawRoundRect(1, 1, w + 6-2, h + 6-2, gCornerRad)	
	
	gfx.setLineWidth(1)
	gfx.drawRoundRect(4, 4, w -2, h -2, gCornerRad)	
	gfx.popContext()
	
	return backgroundImage
end

function generateModDottedBackground(w, h)
	
	local shadowPadding = 7
	local shadowW = w + (shadowPadding*2)
	local shadowH = h + (shadowPadding*2)
	
	local gfx <const> = playdate.graphics
	local templateImage = gfx.image.new(w, h)
	gfx.pushContext(templateImage)
	

	gfx.setLineWidth(2)
	gfx.setColor(gfx.kColorBlack)
	gfx.drawRoundRect(1, 1, w-2, h-2, 8)
	gfx.setLineWidth(1)
	gfx.popContext()
	
	local baseW = shadowW
	local baseH = shadowH
	local baseImage = gfx.image.new(baseW, baseH)
	
	local baseImage2 = gfx.image.new(baseW, baseH, gfx.kColorWhite)
	gfx.pushContext(baseImage2)
	templateImage:drawFaded((baseW - w)/2, (baseH - h)/2, 0.3, gfx.image.kDitherTypeBayer4x4)
	gfx.popContext()
	return baseImage2
end

function generateModBackgroundWithShadow(w, h)
	local gfx <const> = playdate.graphics
	
	local shadowPadding = 7
	local shadowW = w + (shadowPadding*2)
	local shadowH = h + (shadowPadding*2)
	local backgroundShadowImage = gfx.image.new(shadowW, shadowH)
	
	if gModuleDropShadow then
		gfx.pushContext(backgroundShadowImage)
		gfx.setColor(playdate.graphics.kColorBlack)
		gfx.fillRoundRect(shadowPadding/2, shadowPadding/2, shadowW - (shadowPadding/2), shadowH - (shadowPadding/2), gCornerRad)
		gfx.popContext()
	end
	
	local backgroundImage = gfx.image.new(w, h)
	gfx.pushContext(backgroundImage)
	gfx.setLineWidth(2)
	gfx.setColor(playdate.graphics.kColorWhite)
	gfx.fillRoundRect(1, 1, w-2, h-2, gCornerRad)
	gfx.setColor(playdate.graphics.kColorBlack)
	gfx.drawRoundRect(1, 1, w-2, h-2, gCornerRad)	
	gfx.setLineWidth(1)
	gfx.popContext()
	
	local baseW = shadowW + (shadowPadding*2)
	local baseH = shadowH + (shadowPadding*2)
	local baseImage = gfx.image.new(baseW, baseH)
	
	if gModuleDropShadow then
		gfx.pushContext(baseImage)
		backgroundShadowImage:drawBlurred((baseW - shadowW)/2, (baseH - shadowH)/2, 6, 2, playdate.graphics.image.kDitherTypeDiagonalLine)
		gfx.popContext()
	end
	
	local baseImage2 = gfx.image.new(baseW, baseH)
	gfx.pushContext(baseImage2)
	if gModuleDropShadow then
		baseImage:drawFaded(0, 0, 0.6, playdate.graphics.image.kDitherTypeScreen)
	end
	backgroundImage:draw((baseW - w)/2, (baseH - h)/2)
	gfx.popContext()
	return baseImage2
end

function generateModBackgroundWithShadow2(w, h)
	local gfx <const> = playdate.graphics
	
	local shadowPadding = 7
	local shadowW = w + (shadowPadding*2)
	local shadowH = h + (shadowPadding*2)
	local backgroundShadowImage = gfx.image.new(shadowW, shadowH)
	gfx.pushContext(backgroundShadowImage)
	gfx.setColor(playdate.graphics.kColorBlack)
	gfx.fillRoundRect(shadowPadding/2, shadowPadding/2, shadowW - (shadowPadding/2), shadowH - (shadowPadding/2), gCornerRad)
	gfx.popContext()
	
	local backgroundImage = gfx.image.new(w, h)
	gfx.pushContext(backgroundImage)
	gfx.setLineWidth(2)
	gfx.setColor(playdate.graphics.kColorWhite)
	gfx.fillRoundRect(1, 1, w-2, h-2, gCornerRad)
	gfx.setColor(playdate.graphics.kColorBlack)
	gfx.drawRoundRect(1, 1, w-2, h-2, gCornerRad)	
	gfx.setLineWidth(1)
	gfx.popContext()
	
	local baseW = shadowW + (shadowPadding*2)
	local baseH = shadowH + (shadowPadding*2)
	local baseImage = gfx.image.new(baseW, baseH)
	gfx.pushContext(baseImage)
	backgroundShadowImage:drawBlurred((baseW - shadowW)/2, (baseH - shadowH)/2, 4, 4, playdate.graphics.image.kDitherTypeDiagonalLine)
	backgroundImage:draw((baseW - w)/2, (baseH - h)/2)
	
	gfx.popContext()
	
	return baseImage
end