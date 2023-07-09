-- Create the frame and register events
local frame = CreateFrame("FRAME", "HonorableKillAlertFrame")
frame:RegisterEvent("PLAYER_ENTERING_WORLD")
frame:RegisterEvent("PLAYER_PVP_KILLS_CHANGED")

local alertThreshold = 11109 -- Your honorable kill threshold

-- Define the popup dialog
StaticPopupDialogs["HONORABLE_KILL_ALERT"] = {
    text = "You have reached %d honorable kills!",
    button1 = "OK",
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
    preferredIndex = 3,  -- avoid some UI taint, see https://www.wowace.com/news/how-to-avoid-some-ui-taint
}

local function checkHonorableKills()
    local honorableKills, dishonorableKills = GetPVPLifetimeStats() -- Get the lifetime PvP stats
    if honorableKills >= alertThreshold then
        -- Show a popup dialog
        StaticPopup_Show ("HONORABLE_KILL_ALERT", honorableKills)
    end
end

-- Event handler
frame:SetScript("OnEvent", function(self, event, ...)
    if event == "PLAYER_ENTERING_WORLD" or event == "PLAYER_PVP_KILLS_CHANGED" then
        checkHonorableKills()
    end
end)
