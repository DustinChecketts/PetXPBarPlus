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

-- Create a moveable main frame
local f = CreateFrame("Frame", "PetXPBarPlusFrame", UIParent)
f:SetSize(50, 10)
f:SetMovable(true)
f:EnableMouse(true)
f:RegisterForDrag("LeftButton")
f:SetScript("OnDragStart", function(self)
    if not self.isLocked then
        self:StartMoving()
    end
end)
f:SetScript("OnDragStop", function(self)
    self:StopMovingOrSizing()
end)
f:Hide()

-- Ensure it starts unlocked for initial movement if needed
f.isLocked = false

local xpTicker = nil
local layerSyncTicker = nil
local lastXP = 0
local lastNextXP = 0
local lastPetLevel = 0

local function StopLayerSync()
    if layerSyncTicker then
        layerSyncTicker:Cancel()
        layerSyncTicker = nil
    end
end

local function SyncToPetFrameLayer()
    if not PetFrame then
        return
    end

    -- Parent to PetFrame so it stays in the same draw hierarchy
    if f:GetParent() ~= PetFrame then
        f:SetParent(PetFrame)
    end

    f:SetFrameStrata(PetFrame:GetFrameStrata() or "MEDIUM")
    f:SetFrameLevel((PetFrame:GetFrameLevel() or 1) + 5)
end

function AnchorToPetFrame()
    if not PetFrame then
        C_Timer.After(0.1, AnchorToPetFrame)
        return
    end

    SyncToPetFrameLayer()

    f:ClearAllPoints()
    f:SetPoint("TOPLEFT", PetFrame, "BOTTOMLEFT", -2, 12)
end

local function StartLayerSync()
    StopLayerSync()

    local remaining = 10
    layerSyncTicker = C_Timer.NewTicker(0.2, function()
        if PetFrame then
            AnchorToPetFrame()
        end

        remaining = remaining - 1
        if remaining <= 0 then
            StopLayerSync()
        end
    end)
end

-- Initial anchor on load
AnchorToPetFrame()

-- Create the status bar for pet XP
f.bar = CreateFrame("StatusBar", nil, f)
f.bar:SetWidth(46)
f.bar:SetHeight(8)
f.bar:SetPoint("LEFT", f, "LEFT", 2, 0)
f.bar:SetMinMaxValues(0, 100)
f.bar:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")
f.bar:SetStatusBarColor(25 / 255, 125 / 255, 255 / 255)

-- Create a border for the status bar
f.bar.border = f.bar:CreateTexture("PetXPBarBorder", "OVERLAY")
f.bar.border:SetTexture("Interface\\Tooltips\\UI-StatusBar-Border")
f.bar.border:SetAllPoints(f.bar)

-- Create pet level text and offset it from the XP bar
f.bar.text = f.bar:CreateFontString("PetXPBarText", "OVERLAY", "GameFontNormalSmall")
f.bar.text:SetTextColor(1, 0.82, 0)
f.bar.text:SetPoint("BOTTOM", f.bar, "TOP", -16, 0)

local function updatePetXP()
    if HasPetUI() then
        local currXP, nextXP = GetPetExperience()
        local level = UnitLevel("pet")

        if currXP and nextXP and nextXP > 0 then
            f.bar:SetValue((currXP / nextXP) * 100)
        else
            f.bar:SetValue(0)
        end

        if level then
            f.bar.text:SetText(level)
        else
            f.bar.text:SetText("")
        end
    else
        f.bar:SetValue(0)
        f.bar.text:SetText("")
    end
end

function hunterPetActive()
    local hasUI, isHunterPet = HasPetUI()
    if not (hasUI and isHunterPet) then
        f:Hide()

        if xpTicker then
            xpTicker:Cancel()
            xpTicker = nil
        end

        return
    end

    local playerLevel = UnitLevel("player")
    local petLevel = UnitLevel("pet")
    local maxLevel = GetMaxPlayerLevel()

    if playerLevel < maxLevel or petLevel < maxLevel then
        AnchorToPetFrame()
        f:Show()
        updatePetXP()

        if not xpTicker then
            xpTicker = C_Timer.NewTicker(1, function()
                if not f:IsShown() then
                    return
                end

                local currXP, nextXP = GetPetExperience()
                local level = UnitLevel("pet")

                if currXP ~= lastXP or nextXP ~= lastNextXP or level ~= lastPetLevel then
                    AnchorToPetFrame()
                    updatePetXP()
                    lastXP = currXP
                    lastNextXP = nextXP
                    lastPetLevel = level
                end
            end)
        end
    else
        f:Hide()

        if xpTicker then
            xpTicker:Cancel()
            xpTicker = nil
        end
    end
end

-- Unified event handler
local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("UNIT_PET")
eventFrame:RegisterEvent("PLAYER_LOGIN")
eventFrame:RegisterEvent("PLAYER_ALIVE")
eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
eventFrame:RegisterEvent("UNIT_PET_EXPERIENCE")

eventFrame:SetScript("OnEvent", function(_, event, unit)
    if event == "UNIT_PET" or event == "PLAYER_LOGIN" or event == "PLAYER_ALIVE" or event == "PLAYER_ENTERING_WORLD" then
        AnchorToPetFrame()
        hunterPetActive()
        StartLayerSync()
    elseif event == "UNIT_PET_EXPERIENCE" and unit == "pet" then
        AnchorToPetFrame()
        updatePetXP()
    end
end)

-- Keep in sync if Blizzard shows the PetFrame after rebuilds
if PetFrame then
    PetFrame:HookScript("OnShow", function()
        AnchorToPetFrame()
        StartLayerSync()
    end)
end
