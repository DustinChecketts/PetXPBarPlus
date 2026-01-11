-- Chat command to manage PetXPBarPlus
SLASH_PXP1 = "/pxp"
SlashCmdList["PXP"] = function(msg)
    if msg == "reset" then
        AnchorToPetFrame()
        print("PetXPBarPlus has been reset to its default position")

    elseif msg == "lock" then
        PetXPBarPlusFrame.isLocked = true
        PetXPBarPlusFrame:EnableMouse(false)
        print("PetXPBarPlus frame is now LOCKED")

    elseif msg == "unlock" then
        PetXPBarPlusFrame.isLocked = false
        PetXPBarPlusFrame:EnableMouse(true)
        print("PetXPBarPlus is now UNLOCKED and you may drag to reposition")

    else
        print("PetXPBarPlus Commands:")
        print("  /pxp lock     - Lock the XP bar in place")
        print("  /pxp unlock   - Unlock the XP bar for repositioning")
        print("  /pxp reset    - Reset the XP bar to its default position")
    end
end

-- Create a moveable main frame anchored below the pet portrait
local f = CreateFrame("Frame", "PetXPBarPlusFrame", UIParent)
f:SetSize(50, 10)
f:SetMovable(true)
f:EnableMouse(true)
f:RegisterForDrag("LeftButton")
f:SetScript("OnDragStart", f.StartMoving)
f:SetScript("OnDragStop", f.StopMovingOrSizing)
f:SetFrameStrata("HIGH")
f:SetFrameLevel(10)
f:Hide()  -- Hide by default

-- Ensure it starts unlocked for initial movement if needed
f.isLocked = false

-- Function to safely anchor the frame to PetFrame (after UI loads)
function AnchorToPetFrame()
    if PetFrame then
        PetXPBarPlusFrame:ClearAllPoints()
        PetXPBarPlusFrame:SetPoint("TOPLEFT", PetFrame, "BOTTOMLEFT", -2, 12)
    else
        C_Timer.After(0.1, AnchorToPetFrame)
    end
end

-- Call once on load
AnchorToPetFrame()

-- Create the status bar for pet XP
f.bar = CreateFrame("StatusBar", nil, f)
f.bar:SetWidth(46)
f.bar:SetHeight(8)
f.bar:SetPoint("LEFT", f, "LEFT", 2, 0)
f.bar:SetMinMaxValues(0, 100)
f.bar:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")
f.bar:SetStatusBarColor(25/255, 125/255, 255/255)

-- Create a border for the status bar
f.bar.border = f.bar:CreateTexture("PetXPBarBorder", "OVERLAY")
f.bar.border:SetTexture("Interface\\Tooltips\\UI-StatusBar-Border")
f.bar.border:SetAllPoints(f)

-- Create pet level text and offset it from the XP bar
f.bar.text = f.bar:CreateFontString("PetXPBarText", "OVERLAY", "GameFontHighlight")
f.bar.text:SetPoint("BOTTOM", f.bar, "TOP", -16, 0)

-- Function to update the XP bar value
local function updateBar()
    if HasPetUI() then
        local currXP, nextXP = GetPetExperience()
        if currXP and nextXP and nextXP > 0 then
            f.bar:SetValue((currXP / nextXP) * 100)
        else
            f.bar:SetValue(0)
        end
    else
        f.bar:SetValue(0)
    end
end

-- Function to update the pet level text
local function updateText()
    if HasPetUI() then
        local level = UnitLevel("pet")
        if level then
            f.bar.text:SetText(level)
        else
            f.bar.text:SetText("")
        end
    else
        f.bar.text:SetText("")
    end
end

-- Show/Hide the XP bar based on pet status
function hunterPetActive()
    local hasUI, isHunterPet = HasPetUI()
    if not (hasUI and isHunterPet) then
        f:Hide()
        return
    end

    local playerLevel = UnitLevel("player")
    local petLevel = UnitLevel("pet")
    local maxLevel = GetMaxPlayerLevel()

    if playerLevel < maxLevel or petLevel < maxLevel then
        updateBar()
        updateText()
        f:Show()
    else
        f:Hide()
    end
end

-- Event handling for pet experience and pet status updates
local xpEventFrame = CreateFrame("Frame")
xpEventFrame:RegisterEvent("UNIT_PET_EXPERIENCE")
xpEventFrame:SetScript("OnEvent", hunterPetActive)

local petEventFrame = CreateFrame("Frame")
petEventFrame:RegisterEvent("UNIT_PET")
petEventFrame:SetScript("OnEvent", hunterPetActive)

-- Initialize pet status
hunterPetActive()
