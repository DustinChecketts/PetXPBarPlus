-- Chat command to toggle frame lock/unlock and display instructions
SLASH_PXP1 = "/pxp"
SlashCmdList["PXP"] = function(msg)
    if PetXPBarPlusFrame.isLocked then
        PetXPBarPlusFrame.isLocked = false
        PetXPBarPlusFrame:EnableMouse(true)
        print("PetXPBarPlus unlocked. Drag the frame to reposition it. Type /pxp to lock it again.")
    else
        PetXPBarPlusFrame.isLocked = true
        PetXPBarPlusFrame:EnableMouse(false)
        print("PetXPBarPlus locked. Type /pxp to unlock and move it.")
    end
end

-- Create a moveable main frame anchored to UIParent
local f = CreateFrame("Frame", "PetXPBarPlusFrame", UIParent)
f:SetSize(50, 10)
f:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
f:SetMovable(true)
f:EnableMouse(true)
f:RegisterForDrag("LeftButton")
f:SetScript("OnDragStart", f.StartMoving)
f:SetScript("OnDragStop", f.StopMovingOrSizing)
f:Hide()  -- Hide by default

-- Start unlocked
f.isLocked = false

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
    if hasUI and isHunterPet then
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
