-- This AddOn creates and updates a macro for targeting the highest level rogue you kill during a fight.
-- The macro is updated automatically after every fight as soon as you leave combat.
-- The macro targets the rogue, casts Hunter's Mark, sends your pet to attack, and casts Arcane Shot.
-- You can bind this macro to your action bar and use it to easily corpse camp rogues:
-- Just spam this macro while you wait for him to resurrect.
-- However, I do not endorse this behavior in any way!

local addonFrame = CreateFrame("Frame")
addonFrame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
addonFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
addonFrame:RegisterEvent("ADDON_LOADED")
addonFrame:RegisterEvent("UPDATE_MOUSEOVER_UNIT")
addonFrame:RegisterEvent("PLAYER_TARGET_CHANGED")

local rogueNameToUpdate = nil
local highestRogueLevel = 0
local knownRogues = {}

local function UpdateMacro(rogueName)
    local macroText = string.format("#showtooltip\n/targetexact %s\n/cast Hunter's Mark\n/petattack\n/cast Arcane Shot", rogueName)
    local macroIndex = GetMacroIndexByName("RogueTarget")
    if macroIndex > 0 then
        EditMacro(macroIndex, nil, nil, macroText)
        print("Rogue Target Macro updated with name: " .. rogueName)
    else
        print("Error: Macro 'RogueTarget' not found.")
    end
end

local function CreateMacroIfNotExists()
    local macroIndex = GetMacroIndexByName("RogueTarget")
    if macroIndex == 0 then
        local numGeneralMacros, numCharacterMacros = GetNumMacros()
        -- print("General macros: " .. numGeneralMacros .. ", Character macros: " .. numCharacterMacros)
        if numCharacterMacros < MAX_CHARACTER_MACROS then
            local macroId = CreateMacro("RogueTarget", "INV_MISC_QUESTIONMARK", "#showtooltip\n/targetexact\n/cast Hunter's Mark\n/petattack\n/cast Arcane Shot", nil) -- nil for character-specific macros
            if macroId then
                -- print("Macro 'RogueTarget' created with ID: " .. macroId)
            else
                print("Error: Failed to create macro 'RogueTarget'.")
            end
        else
            print("Error: No space for new character-specific macros.")
        end
    else
        -- print("Macro 'RogueTarget' already exists with index: " .. macroIndex)
    end
end

local function CheckAndAddRogue(unit)
    if UnitIsPlayer(unit) then
        local name = UnitName(unit)
        local _, class = UnitClass(unit)
        local level = UnitLevel(unit)
        if class and class:upper() == "ROGUE" then
            if level == -1 then -- Level "??" is represented as -1
                knownRogues[name] = 1000 -- Treat "??" as a very high level
            else
                knownRogues[name] = level
            end
            -- print("Known rogue added: " .. name .. ", level: " .. level)
        else
            -- print("Not a rogue: " .. name .. ", class: " .. (class or "nil") .. ", level: " .. level)
        end
    end
end

local function OnEvent(self, event, ...)
    if event == "COMBAT_LOG_EVENT_UNFILTERED" then
        local _, subEvent, _, _, _, _, _, destGUID, destName, destFlags, _, spellId = CombatLogGetCurrentEventInfo()
        -- print("COMBAT_LOG_EVENT_UNFILTERED: subEvent=" .. subEvent .. ", destName=" .. (destName or "nil") .. ", destFlags=" .. destFlags)
        if subEvent == "UNIT_DIED" and bit.band(destFlags, COMBATLOG_OBJECT_TYPE_PLAYER) ~= 0 then
            -- print("Player died: " .. destName)
            if bit.band(destFlags, COMBATLOG_OBJECT_REACTION_HOSTILE) ~= 0 then
                local rogueLevel = knownRogues[destName]
                if rogueLevel then
                    if rogueLevel > highestRogueLevel then
                        highestRogueLevel = rogueLevel
                        rogueNameToUpdate = destName
                        -- print("Rogue died: " .. destName .. ", level: " .. rogueLevel)
                    end
                else
                    -- print("Player is not a known rogue: " .. destName)
                end
            end
        end
    elseif event == "PLAYER_REGEN_ENABLED" then
        if rogueNameToUpdate then
            UpdateMacro(rogueNameToUpdate)
            rogueNameToUpdate = nil
            highestRogueLevel = 0
        end
    elseif event == "ADDON_LOADED" then
        local addonName = ...
        if addonName == "RogueTargetMacro" then
            -- print("Addon loaded: " .. addonName)
            -- Delay the macro creation to ensure the UI is fully loaded
            C_Timer.After(1, CreateMacroIfNotExists)
        end
    elseif event == "UPDATE_MOUSEOVER_UNIT" then
        CheckAndAddRogue("mouseover")
    elseif event == "PLAYER_TARGET_CHANGED" then
        CheckAndAddRogue("target")
    end
end

addonFrame:SetScript("OnEvent", OnEvent)