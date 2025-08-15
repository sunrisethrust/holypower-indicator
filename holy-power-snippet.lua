local F = Cell and Cell.funcs
if not F then return end

local YELLOW = {1, 1, 0}
local WHITE  = {1, 1, 1}

local playerButton -- the only frame we attach to

local function UpdateHolyPowerDots()
    local holyPower = UnitPower("player", Enum.PowerType.HolyPower) or 0
    local dots = string.rep("•", holyPower)
    if holyPower > 0 then
        return dots, unpack(YELLOW)
    else
        return "", unpack(WHITE)
    end
end

local function CreateHolyPowerIndicator(parent)
    if parent.indicators.holyPowerText then return parent.indicators.holyPowerText end
    
    local holyPowerText = parent.indicators.nameText:CreateFontString(nil, "OVERLAY")
    local font = parent.indicators.nameText.name:GetFont()
    holyPowerText:SetFont(font, 11)
    holyPowerText:SetShadowOffset(1, -1)
    holyPowerText:SetShadowColor(0, 0, 0, 1)
    holyPowerText:SetPoint("TOP", parent, "TOP", 0, -26)
    holyPowerText:SetDrawLayer("OVERLAY", 1)
    
    parent.indicators.holyPowerText = holyPowerText
    return holyPowerText
end

local function UpdateHolyPowerText(unitButton)
    if not unitButton or not unitButton.indicators.holyPowerText then return end
    local dots, r, g, b = UpdateHolyPowerDots()
    unitButton.indicators.holyPowerText:SetText(dots)
    unitButton.indicators.holyPowerText:SetTextColor(r, g, b)
end

local function ClearHolyPowerFromButton(b)
    if b and b.indicators and b.indicators.holyPowerText then
        b.indicators.holyPowerText:SetText("")
        b.indicators.holyPowerText:SetTextColor(unpack(WHITE))
    end
end

local function AttachOrUpdatePlayer()
    local found
    
    -- Find the correct player button
    F.IterateAllUnitButtons(function(b)
            if b and b.states and b.states.unit and UnitIsUnit(b.states.unit, "player") then                
                found = b
            else
                -- make sure no dots linger on non-player frames
                ClearHolyPowerFromButton(b)
            end
    end)
    
    -- If the player frame changed, clear old and attach new
    if found and found ~= playerButton then
        if playerButton then
            -- cleanup old frame
            if playerButton.holyPowerEventFrame then
                playerButton.holyPowerEventFrame:UnregisterAllEvents()
                playerButton.holyPowerEventFrame:SetScript("OnEvent", nil)
                playerButton.holyPowerEventFrame = nil
            end
            ClearHolyPowerFromButton(playerButton)
        end
        
        playerButton = found
        CreateHolyPowerIndicator(playerButton)
        UpdateHolyPowerText(playerButton)
        
        -- event listener for power updates
        local frame = CreateFrame("Frame", nil, playerButton)
        frame:RegisterEvent("UNIT_POWER_UPDATE")
        frame:RegisterEvent("PLAYER_ENTERING_WORLD")
        frame:SetScript("OnEvent", function(_, event, unit)
                if event == "PLAYER_ENTERING_WORLD" or unit == "player" then
                    UpdateHolyPowerText(playerButton)
                end
        end)
        playerButton.holyPowerEventFrame = frame
    elseif found and found == playerButton then
        -- same frame, just update
        UpdateHolyPowerText(playerButton)
    end
end

-- Hook into Cell callbacks
if Cell and Cell.RegisterCallback then
    Cell:RegisterCallback("Create", "HPDots_Create", function()
            C_Timer.After(0, AttachOrUpdatePlayer)
    end)
    Cell:RegisterCallback("UpdateAll", "HPDots_UpdateAll", function()
            C_Timer.After(0, AttachOrUpdatePlayer)
    end)
end

-- Game events for roster changes
local f = CreateFrame("Frame")
f:RegisterEvent("GROUP_ROSTER_UPDATE")
f:RegisterEvent("PLAYER_ENTERING_WORLD")
f:SetScript("OnEvent", function()
        C_Timer.After(0, AttachOrUpdatePlayer)
end)

-- Initial run
C_Timer.After(0.2, AttachOrUpdatePlayer)

