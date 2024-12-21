-- This AddOn for WoW 1.12.1 (not the modern Classic Client!) monitors the zone the player is in for the arrival
-- and departure of high level players.
-- It is intended for spy characters in PvP/Ganking zones like Redridge Mountains.

-- It uses the /who command to get a list of players in the zone and compares it to the previous list to detect changes.
-- When a player enters the zone, a message is displayed with the names of the players who entered.
-- When a player leaves the zone, a message is displayed with the names of the players who left.
-- The level threshold for players to be considered is set to 32 by default, but can be changed in the code.
-- The interval between /who queries is set to 10 seconds by default, but can also be changed in the code.

-- Adjust the levelThreshold and update interval here.
local levelThreshold = 32
local updateInterval = 10 -- seconds
---------------------------------------------------------


local lastUpdate = GetTime()
local whoScanDelay = 1 -- 1-second delay to give the server enough time to provide the results
local lastPlayerList = {}

local function WhoQuery()
    local zone = GetZoneText()
    SendWho("z-\"" .. zone .. "\" " .. levelThreshold .. "-" .. "60")
end

local function GetPlayerList()
    local playerList = {}
    local numWhos = GetNumWhoResults()

    for i = 1, numWhos do
        local name, _, level = GetWhoInfo(i)
        if level >= levelThreshold then
            playerList[name] = true
        end
    end

    return playerList
end

local function ShowAlert(playerList, alertType)
    local message
    local alertFrameName
    local alertTextName

    if alertType == "enter" then
        message = "Players entered zone:\n"
        alertFrameName = "ZoneMonitorAlertFrameEnter"
        alertTextName = "ZoneMonitorAlertTextEnter"
    elseif alertType == "leave" then
        message = "Players left zone:\n"
        alertFrameName = "ZoneMonitorAlertFrameLeave"
        alertTextName = "ZoneMonitorAlertTextLeave"
    end

    for name, _ in pairs(playerList) do
        message = message .. name .. "\n"
    end

    if not getglobal(alertFrameName) then
        local alertFrame = CreateFrame("Frame", alertFrameName, UIParent)
        alertFrame:SetWidth(200)
        alertFrame:SetHeight(100) -- Increase the height to fit more names
        alertFrame:SetPoint("CENTER", UIParent, "CENTER", 0, alertType == "enter" and 50 or -50)
        alertFrame:SetBackdrop({
            bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
            edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
            tile = true, tileSize = 32, edgeSize = 32,
            insets = {left = 11, right = 12, top = 12, bottom = 11},
        })

        local alertText = alertFrame:CreateFontString(alertTextName, "ARTWORK", "GameFontNormal")
        alertText:SetPoint("CENTER", alertFrame, "CENTER")

        local closeButton = CreateFrame("Button", alertFrameName .. "CloseButton", alertFrame, "UIPanelCloseButton")
        closeButton:SetPoint("TOPRIGHT", alertFrame, "TOPRIGHT", -5, -5)
        closeButton:SetScript("OnClick", function() alertFrame:Hide() end)
    end

    getglobal(alertTextName):SetText(message)
    getglobal(alertFrameName):Show()

    if alertType == "enter" then
        PlaySoundFile("Interface\\AddOns\\ZoneMonitor\\alert_enter.ogg")
    elseif alertType == "leave" then
        PlaySoundFile("Interface\\AddOns\\ZoneMonitor\\alert_leave.ogg")
    end
end



local function ComparePlayerLists(currentList)
    local playersEntered = {}
    local playersLeft = {}

    for name, _ in pairs(currentList) do
        if not lastPlayerList[name] then
            playersEntered[name] = true
        end
    end

    for name, _ in pairs(lastPlayerList) do
        if not currentList[name] then
            playersLeft[name] = true
        end
    end

    if next(playersEntered) then
        ShowAlert(playersEntered, "enter")
    end

    if next(playersLeft) then
        ShowAlert(playersLeft, "leave")
    end

    lastPlayerList = currentList
end

local timerFrame = CreateFrame("Frame")
timerFrame:SetScript("OnUpdate", function(self, elapsed)
    local currentTime = GetTime()

    if currentTime - lastUpdate >= updateInterval then
        WhoQuery()
        -- DEFAULT_CHAT_FRAME:AddMessage("ZoneMonitor: Checking who list...")
        lastUpdate = currentTime
    elseif currentTime - lastUpdate >= whoScanDelay then
        local currentPlayerList = GetPlayerList()
        ComparePlayerLists(currentPlayerList)
    end
end)
