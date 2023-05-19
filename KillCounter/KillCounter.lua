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
myText:SetPoint("CENTER", -30, 0)
myText:SetText("Honorable Kills: 0")

local killsPerHourText = myFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
killsPerHourText:SetPoint("CENTER", -24, -15)
killsPerHourText:SetText("Kills per hour: 0")

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
        myText:SetText("Honorable Kills: 0")
        numKills = 0
        startTime = GetTime()
        UpdateKillsPerHour()
        
        -- Start the timer to update the kills per hour value every second
        self:SetScript("OnUpdate", function(self, elapsed)
            UpdateKillsPerHour()
        end)
    elseif event == "COMBAT_LOG_EVENT_UNFILTERED" then
        local timestamp, eventType, hideCaster, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags = CombatLogGetCurrentEventInfo()
        if eventType == "PARTY_KILL" then
            -- Check if the victim was an enemy player
            local destType, destRaidFlags, destIsPlayer = bit.band(destFlags, COMBATLOG_OBJECT_TYPE_MASK), bit.band(destRaidFlags, COMBATLOG_OBJECT_RAIDTARGET_MASK), bit.band(destFlags, COMBATLOG_OBJECT_CONTROL_PLAYER) == COMBATLOG_OBJECT_CONTROL_PLAYER
            if destType == COMBATLOG_OBJECT_TYPE_PLAYER and destIsPlayer and bit.band(destFlags, COMBATLOG_OBJECT_REACTION_MASK) == COMBATLOG_OBJECT_REACTION_HOSTILE then
                -- Increment the kill count and update the text string
                numKills = numKills + 1
                myText:SetText("Honorable Kills: " .. numKills)
                
                -- Announce the kill to group chat
                local killMessage = string.gsub("Enemyplayername abgeknallt!", "Enemyplayername", destName)
                SendChatMessage(killMessage, "PARTY")
            end
        end
    end
end

-- Register the event handler
myFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
myFrame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
myFrame:SetScript("OnEvent", OnEvent)
