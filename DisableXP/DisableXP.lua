-- Function to send the login message
local function SendLoginMessage()
    local message = ".mod xp 0"
    SendChatMessage(message, "SAY")
end

-- Show the pop-up when the player logs in
local function OnLogin()
    StaticPopupDialogs["LOGIN_MESSAGE_POPUP"] = {
        text = "Disable XP?",
        button1 = "Ok",
        button2 = "Cancel",
        OnAccept = function()
            SendLoginMessage()
        end,
        OnCancel = function() end, -- Do nothing when the "Cancel" button is clicked
        timeout = 0,
        whileDead = true,
        hideOnEscape = true,
        preferredIndex = 3,
    }
    
    StaticPopup_Show("LOGIN_MESSAGE_POPUP")
end

local function OnEvent(self, event, isInitialLogin, isReloadingUi)
    if isInitialLogin or isReloadingUi then
        C_Timer.After(1, OnLogin)
    end
end

local LoginMessageFrame = CreateFrame("Frame")
LoginMessageFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
LoginMessageFrame:SetScript("OnEvent", OnEvent)
