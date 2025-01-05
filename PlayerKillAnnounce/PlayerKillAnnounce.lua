-- This AddOn counts the number of player kills since login and announces each kill
-- in the party chat. You can adjust the kill announce message to your liking.
-- "Enemyplayername" will be replaced with the name of the player that was killed.
PlayerKillMessage = "Enemyplayername killed!"
------------------------------------------------------------------------

-- Declare the saved variable
PlayerKillAnnounceDB = PlayerKillAnnounceDB or {}

local playerKillAnnounceFrame = CreateFrame("Frame", "PlayerKillAnnounceFrame", UIParent)
playerKillAnnounceFrame:SetSize(128, 64)
playerKillAnnounceFrame:SetPoint("CENTER")
playerKillAnnounceFrame:EnableMouse(true)                                                   -- Enable mouse interaction on the frame
playerKillAnnounceFrame:SetMovable(true)                                                    -- Allow the frame to be moved
playerKillAnnounceFrame:RegisterForDrag("LeftButton")                                       -- Allow the frame to be dragged with the left mouse button
playerKillAnnounceFrame:SetScript("OnDragStart", playerKillAnnounceFrame.StartMoving)       -- Start moving the frame when dragging begins
playerKillAnnounceFrame:SetScript("OnDragStop", playerKillAnnounceFrame.StopMovingOrSizing) -- Stop moving the frame when dragging stops
playerKillAnnounceFrame:Show()

local playerKillsText = playerKillAnnounceFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
playerKillsText:SetPoint("LEFT", 0, 0)
playerKillsText:SetText("Honorable Kills: 0")

local killsPerHourText = playerKillAnnounceFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
killsPerHourText:SetPoint("LEFT", 0, -15)
killsPerHourText:SetText("Kills per hour: 0")

local startTimeText = playerKillAnnounceFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
startTimeText:SetPoint("LEFT", 0, -30)
startTimeText:SetText("Session Start: N/A") -- This will be updated when session starts

local numKills = 0
local startTime = GetTime()
local EnableKillAnnounce = PlayerKillAnnounceDB.EnableKillAnnounce or true

local function SaveSettings()
    PlayerKillAnnounceDB.EnableKillAnnounce = EnableKillAnnounce
end

local function LoadSettings()
    if PlayerKillAnnounceDB.EnableKillAnnounce ~= nil then
        EnableKillAnnounce = PlayerKillAnnounceDB.EnableKillAnnounce
    end
end

local function UpdateKillsPerHour()
    local currentTime = GetTime()
    local elapsedTime = currentTime - startTime
    local killsPerHour = math.floor(numKills / (elapsedTime / 3600))
    killsPerHourText:SetText("Kills per hour: " .. killsPerHour)
end

local function OnEvent(self, event, ...)
    if event == "PLAYER_ENTERING_WORLD" then
        LoadSettings()
        -- Reset the kill count when the player enters the world
        playerKillsText:SetText("Player Kills    : 0")
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
        local _, combatEvent, _, sourceGUID, sourceName, sourceFlags, _, destGUID, destName, destFlags =
        CombatLogGetCurrentEventInfo()
        if combatEvent == "UNIT_DIED" then
            if bit.band(destFlags, COMBATLOG_OBJECT_TYPE_PLAYER) == COMBATLOG_OBJECT_TYPE_PLAYER and
                bit.band(destFlags, COMBATLOG_OBJECT_REACTION_HOSTILE) == COMBATLOG_OBJECT_REACTION_HOSTILE then
                numKills = numKills + 1
                playerKillsText:SetText("Player Kills    : " .. numKills)

                -- Announce the kill to group chat
                if EnableKillAnnounce then
                    local killMessage = string.gsub(PlayerKillMessage, "Enemyplayername", destName)
                    SendChatMessage(killMessage, "PARTY")
                end
            end
        end
    end
end

-- Register events
playerKillAnnounceFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
playerKillAnnounceFrame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
playerKillAnnounceFrame:SetScript("OnEvent", OnEvent)

SLASH_PLAYERKILLANNOUNCE1 = "/playerkillannounce"
SLASH_PLAYERKILLANNOUNCE2 = "/pka"
SlashCmdList["PLAYERKILLANNOUNCE"] = function(msg)
    if msg == "toggle" then
        EnableKillAnnounce = not EnableKillAnnounce
        SaveSettings()
        -- SendChatMessage(tostring(EnableKillAnnounce), "WHISPER", nil, "Severussnipe")
        if EnableKillAnnounce then
            print("Kill announce messages are now ENABLED.")
        else
            print("Kill announce messages are now DISABLED.")
        end
    else
        print("Usage: /playerkillannounce toggle")
    end
end
