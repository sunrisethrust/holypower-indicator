local F = Cell.funcs

local YELLOW = {1, 1, 0}
local WHITE = {1, 1, 1}

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

    -- Cache font and size (use parent's font, size 11)
    local font = parent.indicators.nameText.name:GetFont()
    local fontSize = 11
    holyPowerText:SetFont(font, fontSize)
    holyPowerText:SetShadowOffset(1, -1)
    holyPowerText:SetShadowColor(0, 0, 0, 1)

    -- Position text just above bottom edge, configurable if needed
    holyPowerText:SetPoint("TOP", parent, "TOP", 0, -26)
    holyPowerText:SetDrawLayer("OVERLAY", 1)

    parent.indicators.holyPowerText = holyPowerText
    return holyPowerText
end

local function UpdateHolyPowerText(unitButton)
    local holyPowerText = unitButton.indicators.holyPowerText
    if not holyPowerText then return end

    local dots, r, g, b = UpdateHolyPowerDots()
    holyPowerText:SetText(dots)
    holyPowerText:SetTextColor(r, g, b)
end

local function InitializeHolyPower()
    F.IterateAllUnitButtons(function(b)
        if b and b.states and b.states.unit == "player" then
            if b.indicators.holyPowerText then return end

            CreateHolyPowerIndicator(b)
            UpdateHolyPowerText(b)

            local frame = CreateFrame("Frame", nil, b)
            frame:RegisterEvent("UNIT_POWER_UPDATE")
            frame:SetScript("OnEvent", function(_, _, unit)
                if unit == "player" then
                    UpdateHolyPowerText(b)
                end
            end)

            -- Optionally store frame for cleanup later:
            b.holyPowerEventFrame = frame
        end
    end)
end

InitializeHolyPower()
