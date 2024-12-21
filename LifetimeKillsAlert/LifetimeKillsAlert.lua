-- This simple AddOn displays a popup dialog when the player reaches a certain number of honorable kills.
-- Can be used if you want to make a screenshot of a specific number of honorable kills.
KillAlertThreshold = 11109 -- Your honorable kill threshold at which you want to be alerted.
------------------------------------------------------------------------------------------------

local frame = CreateFrame("FRAME", "HonorableKillAlertFrame")
frame:RegisterEvent("PLAYER_ENTERING_WORLD")
frame:RegisterEvent("PLAYER_PVP_KILLS_CHANGED")

StaticPopupDialogs["HONORABLE_KILL_ALERT"] = {
    text = "You have reached %d honorable kills!",
    button1 = "OK",
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
    preferredIndex = 3,  -- avoid some UI taint, see https://www.wowace.com/news/how-to-avoid-some-ui-taint
}

local function checkHonorableKills()
    local honorableKills, dishonorableKills = GetPVPLifetimeStats()
    if honorableKills >= KillAlertThreshold then
        StaticPopup_Show("HONORABLE_KILL_ALERT", honorableKills)
    end
end

-- Event handler
frame:SetScript("OnEvent", function(self, event, ...)
    if event == "PLAYER_ENTERING_WORLD" or event == "PLAYER_PVP_KILLS_CHANGED" then
        checkHonorableKills()
    end
end)
