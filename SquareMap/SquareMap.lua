local escapes = {
	["|c%x%x%x%x%x%x%x%x"] = "", -- color start
	["|r"] = "",                 -- color end
	["|H.-|h(.-)|h"] = "%1",     -- links
	["|T.-|t"] = "",             -- textures
	["{.-}"] = "",               -- raid target icons
}

targetBtn = CreateFrame("Button", "targetBtn", UIParent, "BaumMapSecureActionButtonTemplate")

local function unescape(str)
	for k, v in pairs(escapes) do
		str = gsub(str, k, v)
	end

	for substr in str:gmatch("%S+") do return substr end
end

function BM_Click_Target(button)
	local name = GameTooltipTextLeft1:GetText()
	if name then
		name = unescape(name);
		local x, y = GetCursorPosition()
		local offsx = 225
		local offsy = 125
		-- DEFAULT_CHAT_FRAME:AddMessage("x "..x)
		-- DEFAULT_CHAT_FRAME:AddMessage("y "..y)
		targetBtn:ClearAllPoints()
		targetBtn:SetPoint("CENTER", UIParent, 0, -250)
		targetBtn:SetWidth(140)
		targetBtn:SetHeight(140)
		targetBtn:SetAttribute("macrotext", "/targetexact " .. name)
		targetBtn:Show()
		C_Timer.After(0.4, function() targetBtn:Hide() end)
	end
end

function hide_clock()
	LoadAddOn("Blizzard_TimeManager")
	local region = TimeManagerClockButton:GetRegions()
	region:Hide()
	TimeManagerClockButton:Hide()
end

function BM_Setup()
	Minimap:SetScript("OnMouseUp", function(frame, button)
		local name = GameTooltipTextLeft1:GetText()
		if name then
			if IsShiftKeyDown() then
				Minimap_OnClick(frame, button)
			else
				BM_Click_Target(button)
			end
		else
			Minimap_OnClick(frame, button)
		end
	end)

	Minimap:EnableMouseWheel(true)
	Minimap:SetScript("OnMouseWheel", function(frame, d)
		if d > 0 then
			MinimapZoomIn:Click()
		elseif d < 0 then
			MinimapZoomOut:Click()
		end
	end)

	local hideAll = {
		"MinimapBorder",         -- Outer border
		"MinimapBorderTop",
		"MinimapNorthTag",       -- Compass
		"MiniMapWorldMapButton", -- World map button
		"MinimapZoneTextButton", -- Zone text
		"MinimapZoomIn",         -- Zoom in
		"MinimapZoomOut",        -- Zoom out
		"GameTimeFrame",         -- Time button
		"SubZoneTextFrame",
		"MinimapToggleButton"
	}

	for i, v in pairs(hideAll) do
		local element = getglobal(v)
		if element then
			element:Hide()
		else
			print("UI element not found:", v) -- Debug message
		end
	end

	Minimap:SetStaticPOIArrowTexture("")

	Minimap:SetPoint("CENTER", UIParent, 0, -250)
	Minimap:SetMaskTexture("Interface\\BUTTONS\\WHITE8X8")
	hide_clock()
end

BM_Setup()
