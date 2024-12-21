-- Create a new frame to display the number of honorable kills
local myFrame = CreateFrame("Frame", "MyAddonFrame", UIParent)
myFrame:SetSize(128, 64)
myFrame:SetPoint("CENTER")
myFrame:EnableMouse(true) -- Enable mouse interaction on the frame
myFrame:SetMovable(true) -- Allow the frame to be moved
myFrame:RegisterForDrag("LeftButton") -- Allow the frame to be dragged with the left mouse button
myFrame:SetScript("OnDragStart", myFrame.StartMoving) -- Start moving the frame when dragging begins
myFrame:SetScript("OnDragStop", myFrame.StopMovingOrSizing) -- Stop moving the frame when dragging stops
myFrame:Show()

-- Create a new text string to display the number of honorable kills and kills per hour
local myText = myFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
myText:SetPoint("LEFT", 0, 0)
myText:SetText("Honorable Kills: 0")

local killsPerHourText = myFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
killsPerHourText:SetPoint("LEFT", 0, -15)
killsPerHourText:SetText("Kills per hour: 0")

-- Create a new text string to display the session start time
local startTimeText = myFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
startTimeText:SetPoint("LEFT", 0, -30)  -- Change position according to your needs
startTimeText:SetText("Session Start: N/A")  -- This will be updated when session starts

-- Variables to track the number of kills and the time elapsed
local numKills = 0
local startTime = GetTime()

-- Function to update the kills per hour value
local function UpdateKillsPerHour()
    local currentTime = GetTime()
    local elapsedTime = currentTime - startTime
    local killsPerHour = math.floor(numKills / (elapsedTime / 3600))
    killsPerHourText:SetText("Kills per hour: " .. killsPerHour)
end

-- Create an event handler to count honorable kills and announce them to group chat
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

        -- Set start time and update the text string
        local sessionStart = date("%H:%M")  -- Adjust the format according to your needs
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
myFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
myFrame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
myFrame:SetScript("OnEvent", OnEvent)
