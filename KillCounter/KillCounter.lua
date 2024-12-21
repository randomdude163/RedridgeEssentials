-- Create a new frame to display the number of honorable kills
local killStatisticsFrame = CreateFrame("Frame", "KillStatisticsFrame", UIParent)
killStatisticsFrame:SetSize(128, 64)
killStatisticsFrame:SetPoint("CENTER")
killStatisticsFrame:EnableMouse(true) -- Enable mouse interaction on the frame
killStatisticsFrame:SetMovable(true) -- Allow the frame to be moved
killStatisticsFrame:RegisterForDrag("LeftButton") -- Allow the frame to be dragged with the left mouse button
killStatisticsFrame:SetScript("OnDragStart", killStatisticsFrame.StartMoving) -- Start moving the frame when dragging begins
killStatisticsFrame:SetScript("OnDragStop", killStatisticsFrame.StopMovingOrSizing) -- Stop moving the frame when dragging stops
killStatisticsFrame:Show()

local myText = killStatisticsFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
myText:SetPoint("LEFT", 0, 0)
myText:SetText("Honorable Kills: 0")

local killsPerHourText = killStatisticsFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
killsPerHourText:SetPoint("LEFT", 0, -15)
killsPerHourText:SetText("Kills per hour: 0")

local startTimeText = killStatisticsFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
startTimeText:SetPoint("LEFT", 0, -30)
startTimeText:SetText("Session Start: N/A")  -- This will be updated when session starts

local numKills = 0
local startTime = GetTime()


local function UpdateKillsPerHour()
    local currentTime = GetTime()
    local elapsedTime = currentTime - startTime
    local killsPerHour = math.floor(numKills / (elapsedTime / 3600))
    killsPerHourText:SetText("Kills per hour: " .. killsPerHour)
end


local function OnEvent(self, event, ...)
    if event == "PLAYER_ENTERING_WORLD" then
        -- Reset the kill count when the player enters the world
        myText:SetText("Player Kills    : 0")
        numKills = 0
        startTime = GetTime()
        UpdateKillsPerHour()
        
        -- Start the timer to update the kills per hour value every second
        self:SetScript("OnUpdate", function(self, elapsed)
            UpdateKillsPerHour()
        end)

        local sessionStart = date("%H:%M")
        startTimeText:SetText("Session Start : " .. sessionStart)
        
    elseif event == "COMBAT_LOG_EVENT_UNFILTERED" then
        local _, combatEvent, _, sourceGUID, sourceName, sourceFlags, _, destGUID, destName, destFlags = CombatLogGetCurrentEventInfo()
        if combatEvent == "UNIT_DIED" then
            if bit.band(destFlags, COMBATLOG_OBJECT_TYPE_PLAYER) == COMBATLOG_OBJECT_TYPE_PLAYER and
               bit.band(destFlags, COMBATLOG_OBJECT_REACTION_HOSTILE) == COMBATLOG_OBJECT_REACTION_HOSTILE then
                numKills = numKills + 1
                myText:SetText("Player Kills    : " .. numKills)
                
                -- Announce the kill to group chat
                local killMessage = string.gsub("Enemyplayername abgeknallt!", "Enemyplayername", destName)
                SendChatMessage(killMessage, "PARTY")
            end
        end
    end
end

-- Register events
killStatisticsFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
killStatisticsFrame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
killStatisticsFrame:SetScript("OnEvent", OnEvent)
