-- Frame
local f = CreateFrame("Frame", nil, UIParent)
f:SetSize(50, 10)
f:ClearAllPoints()
f:SetPoint("CENTER", PetFrame.portrait, "CENTER", -3, -22)

-- Status Bar
f.bar = CreateFrame("StatusBar", nil, f)
f.bar:SetWidth(46)
f.bar:SetHeight(8)
f.bar:SetPoint("LEFT", f, "LEFT", 2, 0)
f.bar:SetMinMaxValues(0, 100)
f.bar:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")
f.bar:SetStatusBarColor(25/255, 125/255, 255/255)

-- Status Bar Border
f.bar.border = f.bar:CreateTexture("PetXPBarBorder", "OVERLAY")
f.bar.border:SetTexture("Interface\\Tooltips\\UI-StatusBar-Border")
f.bar.border:SetAllPoints(f)

-- Pet Level Text
f.bar.text = f.bar:CreateFontString("PetXPBarText", "OVERLAY", "GameFontHighlight")
f.bar.text:SetPoint("LEFT", PetFrame.portrait, "LEFT", -10, -12)

-- Update Status Bar with Pet XP
function updateBar()
    local currXP, nextXP = GetPetExperience()
    -- print("Pet Xp: " .. string.format("%2.2f", (currXP / nextXP) * 100) .. "%") --debug
    f.bar:SetValue((currXP / nextXP) * 100)
end

-- Update Pet Level Text with pet level
function updateText()
    local level = UnitLevel("pet")
    -- print("Pet Level: " .. level) --debug
    f.bar.text:SetText(level)
end

-- Update Pet Experience Progress
local initer = CreateFrame("Frame")
initer:RegisterEvent("UNIT_PET_EXPERIENCE")
initer:SetScript("OnEvent", function(self, event)
    updateBar()
    updateText()
end)

-- Event Handling
local reloader = CreateFrame("Frame")
reloader:RegisterEvent("UNIT_PET")
reloader:SetScript("OnEvent", function(self, event)
    hunterPetActive()
end)

-- Show/Hide when Pet is Present/Not Present
function hunterPetActive()
    local hasUI, isHunterPet = HasPetUI()
    f:Hide()
    if hasUI then
        if isHunterPet then
            updateBar()
            updateText()
            f:Show()
        end
    end
end

hunterPetActive()
