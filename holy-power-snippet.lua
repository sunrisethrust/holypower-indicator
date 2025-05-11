local F = Cell.funcs

-- Create a function to update the Holy Power dots
local function UpdateHolyPowerDots()
    local holyPower = UnitPower("player", Enum.PowerType.HolyPower) or 0    
    local dots = string.rep("•", holyPower) -- Create dots based on Holy Power    
    
    -- Return the dots and their color (yellow for active, white for none)
    if holyPower > 0 then
        return dots, 1, 1, 0 -- Yellow color
    else
        return "", 1, 1, 1 -- No dots, white color
    end
end

-- Create the Holy Power display text
local function CreateHolyPowerIndicator(parent)
    local holyPowerText = parent.indicators.nameText:CreateFontString(nil, "OVERLAY")
    
    -- Use the parent font or customize
    local font = parent.indicators.nameText.name:GetFont()
    local fontSize = 11
    holyPowerText:SetFont(font, fontSize, "") -- font, size, flags
    holyPowerText:SetShadowOffset(1, -1)
    holyPowerText:SetShadowColor(0, 0, 0, 1)
    
    -- Dynamically calculate position based on unit frame dimensions
    local width = parent:GetWidth() / 2
    local height = parent:GetHeight() / 2
    
    -- Position the Holy Power text
    holyPowerText:SetPoint("TOP", parent, "TOP", 0, -26) -- Adjust the vertical offset as needed    
  
    -- Ensure it's drawn on a higher layer to prevent overlapping with the unit frame
    holyPowerText:SetDrawLayer("OVERLAY", 1)
  
    parent.indicators.holyPowerText = holyPowerText
    
    return holyPowerText
end

-- Update Holy Power text for the given unit button
local function UpdateHolyPowerText(unitButton)
    if not unitButton.indicators.holyPowerText then
        return -- Ensure the Holy Power text indicator exists
    end
    
    local dots, r, g, b = UpdateHolyPowerDots()
    unitButton.indicators.holyPowerText:SetText(dots)
    unitButton.indicators.holyPowerText:SetTextColor(r, g, b)
end

-- Hook into Cell unit buttons
local function InitializeHolyPower()
    F.IterateAllUnitButtons(function(b)
            if b and b.states and b.states.unit == "player" then
                -- Create the Holy Power indicator for the player unit
                local holyPowerText = CreateHolyPowerIndicator(b)
                
                -- Update Holy Power dots on creation
                UpdateHolyPowerText(b)
                
                -- Set up an event listener for Holy Power changes
                local frame = CreateFrame("Frame", nil, b)
                frame:RegisterEvent("UNIT_POWER_UPDATE")
                frame:SetScript("OnEvent", function(_, event, unit)
                        if unit == "player" then
                            UpdateHolyPowerText(b)
                        end
                end)
            end
    end)
end

-- Call the initialization function
InitializeHolyPower()
