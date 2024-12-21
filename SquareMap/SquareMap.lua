-- This AddOn makes the minimap square and removes the frame, buttons and other stuff.
-- It allows you to double-click Humanoid Tracking pips on the map to target the player.
-- This is a port of the 1.12.1 AddOn BaumMap by EinBaum (https://github.com/EinBaum)
-- to the modern Classic Client.

local targetBtn = CreateFrame("Button", "targetBtn", UIParent, "SquareMapSecureActionButtonTemplate")

local function unescape(str)
	local escapes = {
		["|c%x%x%x%x%x%x%x%x"] = "", -- color start
		["|r"] = "",              -- color end
		["|H.-|h(.-)|h"] = "%1",  -- links
		["|T.-|t"] = "",          -- textures
		["{.-}"] = "",            -- raid target icons
	}

	for k, v in pairs(escapes) do
		str = gsub(str, k, v)
	end

	for substr in str:gmatch("%S+") do return substr end
end

local function square_map_click_target(button)
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

local function hide_minimap_clock_frame()
	LoadAddOn("Blizzard_TimeManager")
	local region = TimeManagerClockButton:GetRegions()
	region:Hide()
	TimeManagerClockButton:Hide()
end

local function hide_unwanted_minimap_elements()
	local hideAll = {
		"MinimapBorder",   -- Outer border
		"MinimapBorderTop",
		"MinimapNorthTag", -- Compass
		"MiniMapWorldMapButton", -- World map button
		"MinimapZoneTextButton", -- Zone text
		"MinimapZoomIn",   -- Zoom in
		"MinimapZoomOut",  -- Zoom out
		"GameTimeFrame",   -- Time button
		"SubZoneTextFrame",
		"MinimapToggleButton"
	}

	for i, v in pairs(hideAll) do
		local element = getglobal(v)
		if element then
			element:Hide()
		else
			print("UI element not found:", v)
		end
	end

	Minimap:SetStaticPOIArrowTexture("") -- remove arrow that points to nearest town
	hide_minimap_clock_frame()
end

local function enable_scroll_wheel_zooming()
	Minimap:EnableMouseWheel(true)
	Minimap:SetScript("OnMouseWheel", function(frame, d)
		if d > 0 then
			MinimapZoomIn:Click()
		elseif d < 0 then
			MinimapZoomOut:Click()
		end
	end)
end

local function center_minimap_and_make_square()
	Minimap:SetPoint("CENTER", UIParent, 0, -250)
	Minimap:SetMaskTexture("Interface\\BUTTONS\\WHITE8X8")
end

local function square_map_setup()
	Minimap:SetScript("OnMouseUp", function(frame, button)
		local name = GameTooltipTextLeft1:GetText()
		if name then
			if IsShiftKeyDown() then  -- Shift click to send ping
				Minimap_OnClick(frame, button)
			else
				square_map_click_target(button)
			end
		else
			Minimap_OnClick(frame, button)
		end
	end)

	hide_unwanted_minimap_elements()
	enable_scroll_wheel_zooming()
	center_minimap_and_make_square()	
end

square_map_setup()
