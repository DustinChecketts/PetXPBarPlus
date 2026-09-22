local ADDON_NAME = ...
PetXPBarPlus = PetXPBarPlus or {}
local Addon = PetXPBarPlus
local PREFIX = "|cff1980ffPetXPBarPlus|r"

local function Print(message)
    print(PREFIX .. ": " .. message)
end

local function SafeNumber(value)
    return type(value) == "number" and value or nil
end

local function GetHunterPetState()
    if type(HasPetUI) ~= "function" then
        return false, false
    end

    local ok, hasUI, isHunterPet = pcall(HasPetUI)
    if not ok then
        return false, false
    end

    return hasUI == true, isHunterPet == true
end

local function GetPetXP()
    if type(GetPetExperience) ~= "function" then
        return nil, nil
    end

    local ok, currentXP, nextXP = pcall(GetPetExperience)
    if not ok then
        return nil, nil
    end

    return SafeNumber(currentXP), SafeNumber(nextXP)
end

local function GetUnitLevel(unit)
    if type(UnitLevel) ~= "function" then
        return nil
    end

    local ok, level = pcall(UnitLevel, unit)
    if not ok then
        return nil
    end

    return SafeNumber(level)
end

local function GetLevelCap()
    if type(GetEffectivePlayerMaxLevel) == "function" then
        local ok, level = pcall(GetEffectivePlayerMaxLevel)
        if ok and SafeNumber(level) then
            return level
        end
    end

    if type(GetMaxPlayerLevel) == "function" then
        local ok, level = pcall(GetMaxPlayerLevel)
        if ok and SafeNumber(level) then
            return level
        end
    end

    return nil
end

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
f.isLocked = false

local xpTicker
local layerSyncTicker
local lastXP
local lastNextXP
local lastPetLevel

local function GetNativePetFrame()
    return _G.PetFrame
end

local function StopLayerSync()
    if layerSyncTicker then
        layerSyncTicker:Cancel()
        layerSyncTicker = nil
    end
end

local function SyncToPetFrameLayer()
    local petFrame = GetNativePetFrame()
    if not petFrame then
        return false
    end

    if f:GetParent() ~= petFrame then
        f:SetParent(petFrame)
    end

    f:SetFrameStrata(petFrame:GetFrameStrata() or "MEDIUM")
    f:SetFrameLevel((petFrame:GetFrameLevel() or 1) + 5)
    return true
end

local function AnchorToPetFrame()
    local petFrame = GetNativePetFrame()
    if not petFrame then
        return false
    end

    SyncToPetFrameLayer()
    f:ClearAllPoints()
    f:SetPoint("TOPLEFT", petFrame, "BOTTOMLEFT", -2, 12)

    -- Keep the level badge independent of the tiny XP container. Anchor it
    -- directly to Blizzard's PetFrame so it cannot be clipped or lost when
    -- the XP frame is repositioned/reparented.
    f.levelBadge:SetParent(petFrame)
    f.levelBadge:SetFrameStrata(petFrame:GetFrameStrata() or "MEDIUM")
    f.levelBadge:SetFrameLevel((petFrame:GetFrameLevel() or 1) + 8)
    f.levelBadge:ClearAllPoints()
    f.levelBadge:SetPoint("BOTTOMLEFT", petFrame, "BOTTOMLEFT", -13, 2)
    return true
end

local function StartLayerSync()
    StopLayerSync()

    local remaining = 10
    layerSyncTicker = C_Timer.NewTicker(0.2, function()
        AnchorToPetFrame()

        remaining = remaining - 1
        if remaining <= 0 then
            StopLayerSync()
        end
    end)
end

f.bar = CreateFrame("StatusBar", nil, f)
f.bar:SetWidth(46)
f.bar:SetHeight(8)
f.bar:SetPoint("LEFT", f, "LEFT", 2, 0)
f.bar:SetMinMaxValues(0, 100)
f.bar:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")
-- Forever uses purple for the player's experience bar; mirror that visual language.
f.bar:SetStatusBarColor(0.58, 0.24, 0.86)

f.bar.border = f.bar:CreateTexture("PetXPBarBorder", "OVERLAY")
f.bar.border:SetTexture("Interface\\Tooltips\\UI-StatusBar-Border")
f.bar.border:SetAllPoints(f.bar)

-- Pet level badge. The circular targeting-frame texture gives us a Blizzard-native
-- bronze/gold ring that visually pairs with Forever's character level badge.
f.levelBadge = CreateFrame("Frame", nil, f)
f.levelBadge:SetSize(23, 23)
-- Match the Anniversary/TBC placement: level sits just above the XP bar\nf.levelBadge:SetPoint("BOTTOM", f.bar, "TOP", -16, -1)
f.levelBadge:SetFrameLevel(f:GetFrameLevel() + 8)

-- Build the pet badge from simple native primitives instead of reusing
-- UI-TargetingFrame-LevelBackground. That atlas is not a standalone circle
-- in Forever and rendered as the square/gradient artifact seen in testing.
f.levelBadge.outer = f.levelBadge:CreateTexture(nil, "BACKGROUND")
f.levelBadge.outer:SetPoint("CENTER")
f.levelBadge.outer:SetSize(23, 23)
f.levelBadge.outer:SetTexture("Interface\\COMMON\\Indicator-Gray")
f.levelBadge.outer:SetVertexColor(0.64, 0.39, 0.16, 1)

f.levelBadge.inner = f.levelBadge:CreateTexture(nil, "BORDER")
f.levelBadge.inner:SetPoint("CENTER")
f.levelBadge.inner:SetSize(21, 21)
f.levelBadge.inner:SetTexture("Interface\\COMMON\\Indicator-Gray")
f.levelBadge.inner:SetVertexColor(0.06, 0.06, 0.06, 1)

f.levelBadge.text = f.levelBadge:CreateFontString("PetXPBarText", "OVERLAY", "GameFontNormalSmall")
f.levelBadge.text:SetPoint("CENTER", 0, 0)
f.levelBadge.text:SetTextColor(1, 1, 1)
local badgeFont, _, badgeFlags = f.levelBadge.text:GetFont()
if badgeFont then
    f.levelBadge.text:SetFont(badgeFont, 7, badgeFlags)
end

local function UpdatePetXP()
    local hasUI, isHunterPet = GetHunterPetState()
    if not (hasUI and isHunterPet) then
        f.bar:SetValue(0)
        f.levelBadge.text:SetText("")
        return
    end

    local currentXP, nextXP = GetPetXP()
    local level = GetUnitLevel("pet")

    if currentXP and nextXP and nextXP > 0 then
        f.bar:SetValue((currentXP / nextXP) * 100)
    else
        f.bar:SetValue(0)
    end

    f.levelBadge.text:SetText(level or "")
end

local function StopXPTicker()
    if xpTicker then
        xpTicker:Cancel()
        xpTicker = nil
    end
end

local function ApplyDisplayOptions()
    local db = Addon.db
    if not db then return end
    if db.showXPBar then f.bar:Show() else f.bar:Hide() end
    if db.showPetLevel then f.levelBadge:Show() else f.levelBadge:Hide() end
end
Addon.ApplyDisplayOptions = ApplyDisplayOptions

local function HunterPetActive()
    local hasUI, isHunterPet = GetHunterPetState()
    if not (hasUI and isHunterPet) then
        f:Hide()
        f.levelBadge:Hide()
        StopXPTicker()
        return
    end

    local playerLevel = GetUnitLevel("player")
    local petLevel = GetUnitLevel("pet")
    local maxLevel = GetLevelCap()

    -- If Forever withholds one of these values, prefer showing the frame
    -- rather than incorrectly hiding it.
    local shouldShow = true
    if playerLevel and petLevel and maxLevel then
        shouldShow = playerLevel < maxLevel or petLevel < maxLevel
    end

    if not shouldShow then
        f:Hide()
        f.levelBadge:Hide()
        StopXPTicker()
        return
    end

    AnchorToPetFrame()
    f:Show()
    UpdatePetXP()
    ApplyDisplayOptions()

    if not xpTicker then
        xpTicker = C_Timer.NewTicker(1, function()
            if not f:IsShown() then
                return
            end

            local currentXP, nextXP = GetPetXP()
            local level = GetUnitLevel("pet")

            if currentXP ~= lastXP or nextXP ~= lastNextXP or level ~= lastPetLevel then
                AnchorToPetFrame()
                UpdatePetXP()
                lastXP = currentXP
                lastNextXP = nextXP
                lastPetLevel = level
            end
        end)
    end
end

local function PrintDiagnostics()
    local version, build, buildDate, interfaceVersion = GetBuildInfo()
    local hasUI, isHunterPet = GetHunterPetState()
    local currentXP, nextXP = GetPetXP()

    Print("diagnostics")
    print("  Client: " .. tostring(version) .. " (" .. tostring(build) .. "), Interface " .. tostring(interfaceVersion))
    print("  PetFrame: " .. tostring(GetNativePetFrame() ~= nil))
    print("  HasPetUI: " .. tostring(hasUI) .. ", hunter pet: " .. tostring(isHunterPet))
    print("  GetPetExperience API: " .. tostring(type(GetPetExperience) == "function"))
    print("  Pet XP: " .. tostring(currentXP) .. " / " .. tostring(nextXP))
    print("  Pet level: " .. tostring(GetUnitLevel("pet")))
    print("  Level cap: " .. tostring(GetLevelCap()))
end

SLASH_PXP1 = "/pxp"
SlashCmdList.PXP = function(msg)
    msg = strtrim((msg or ""):lower())

    if msg == "reset" then
        if AnchorToPetFrame() then
            Print("reset to its default position")
        else
            Print("could not find Blizzard's PetFrame")
        end
    elseif msg == "lock" then
        f.isLocked = true
        f:EnableMouse(false)
        Print("frame is now LOCKED")
    elseif msg == "unlock" then
        f.isLocked = false
        f:EnableMouse(true)
        Print("is now UNLOCKED and may be dragged to reposition")
    elseif msg == "options" or msg == "config" then
        if PetXPBarPlus and PetXPBarPlus.OpenOptions then
            PetXPBarPlus.OpenOptions()
        else
            Print("open Options > AddOns > PetXPBarPlus")
        end
    elseif msg == "debug" or msg == "diag" then
        PrintDiagnostics()
    else
        Print("Commands:")
        print("  /pxp lock   - Lock the XP bar in place")
        print("  /pxp unlock - Unlock the XP bar for repositioning")
        print("  /pxp reset  - Reset the XP bar to its default position")
        print("  /pxp options - Open the options pane")
        print("  /pxp debug   - Print Forever API diagnostics")
    end
end

local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("UNIT_PET")
eventFrame:RegisterEvent("PLAYER_LOGIN")
eventFrame:RegisterEvent("PLAYER_ALIVE")
eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
eventFrame:RegisterEvent("UNIT_PET_EXPERIENCE")

eventFrame:SetScript("OnEvent", function(_, event, unit)
    if event == "UNIT_PET" or event == "PLAYER_LOGIN" or event == "PLAYER_ALIVE" or event == "PLAYER_ENTERING_WORLD" then
        AnchorToPetFrame()
        HunterPetActive()
        StartLayerSync()
    elseif event == "UNIT_PET_EXPERIENCE" and (unit == nil or unit == "pet") then
        AnchorToPetFrame()
        UpdatePetXP()
    end
end)

local function HookPetFrame()
    local petFrame = GetNativePetFrame()
    if not petFrame or petFrame.__PetXPBarPlusHooked then
        return
    end

    petFrame.__PetXPBarPlusHooked = true
    petFrame:HookScript("OnShow", function()
        AnchorToPetFrame()
        HunterPetActive()
        StartLayerSync()
    end)
end

if GetNativePetFrame() then
    HookPetFrame()
else
    C_Timer.After(0, HookPetFrame)
    C_Timer.After(1, HookPetFrame)
end
