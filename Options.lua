local ADDON_NAME = ...
PetXPBarPlus = PetXPBarPlus or {}
local Addon = PetXPBarPlus
local Compat = Addon.Compat

local PURPLE = { r = 0.58, g = 0.24, b = 0.86 }
local BLUE = { r = 25 / 255, g = 125 / 255, b = 255 / 255 }

local DEFAULTS = {
    showXPBar = true,
    showPetLevel = true,
    alwaysShowXPBar = false,
    alwaysShowPetLevel = false,
    locked = false,
}
Addon.DEFAULTS = DEFAULTS

local function CopyColor(color)
    return { r = color.r, g = color.g, b = color.b }
end

local function InitializeDB()
    PetXPBarPlusDB = type(PetXPBarPlusDB) == "table" and PetXPBarPlusDB or {}
    Addon.db = PetXPBarPlusDB

    for key, value in pairs(DEFAULTS) do
        if Addon.db[key] == nil then
            Addon.db[key] = value
        end
    end

    if type(Addon.db.xpColor) ~= "table" then
        Addon.db.xpColor = CopyColor(Compat.isForever and PURPLE or BLUE)
    end
end

local controls = {}
local colorSwatch

local function Apply()
    if Addon.ApplyDisplayOptions then Addon.ApplyDisplayOptions() end
    if Addon.ApplyXPBarColor then Addon.ApplyXPBarColor() end
    if Addon.SetLocked then Addon.SetLocked(Addon.db.locked) end
end

local function RefreshControls()
    for key, check in pairs(controls) do
        check:SetChecked(Addon.db[key])
    end
    if colorSwatch and Addon.db.xpColor then
        colorSwatch.texture:SetColorTexture(Addon.db.xpColor.r, Addon.db.xpColor.g, Addon.db.xpColor.b)
    end
end

local function SetColor(color)
    Addon.db.xpColor = CopyColor(color)
    RefreshControls()
    Apply()
end

local function ResetDefaults()
    for key, value in pairs(DEFAULTS) do
        Addon.db[key] = value
    end
    Addon.db.xpColor = CopyColor(Compat.isForever and PURPLE or BLUE)
    if Addon.ResetPosition then Addon.ResetPosition() end
    RefreshControls()
    Apply()
end
Addon.ResetDefaults = ResetDefaults

InitializeDB()

local panel = CreateFrame("Frame", "PetXPBarPlusOptionsPanel")
panel.name = "PetXPBarPlus"

local title = panel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
title:SetPoint("TOPLEFT", 16, -16)
title:SetText("PetXPBarPlus")

local subtitle = panel:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
subtitle:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -8)
subtitle:SetText("Pet experience display options.")

local function MakeCheckbox(label, key, y)
    local check = CreateFrame("CheckButton", nil, panel, "UICheckButtonTemplate")
    check:SetPoint("TOPLEFT", 16, y)
    local textRegion = check.Text or check.text
    if textRegion then textRegion:SetText(label) end
    controls[key] = check
    check:SetScript("OnShow", function(self) self:SetChecked(Addon.db[key]) end)
    check:SetScript("OnClick", function(self)
        Addon.db[key] = self:GetChecked() and true or false
        Apply()
    end)
    return check
end

MakeCheckbox("Show XP Bar", "showXPBar", -58)
MakeCheckbox("Show Pet Level", "showPetLevel", -88)

local behaviorTitle = panel:CreateFontString(nil, "ARTWORK", "GameFontNormal")
behaviorTitle:SetPoint("TOPLEFT", 16, -126)
behaviorTitle:SetText("Visibility Behavior")

MakeCheckbox("Always show XP Bar", "alwaysShowXPBar", -150)
MakeCheckbox("Always show Pet Level", "alwaysShowPetLevel", -180)

local behaviorNote = panel:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
behaviorNote:SetPoint("TOPLEFT", 42, -208)
behaviorNote:SetWidth(430)
behaviorNote:SetJustifyH("LEFT")
behaviorNote:SetText("By default, the XP bar hides when your pet cannot gain XP, and the pet level hides at the level cap.")

local appearanceTitle = panel:CreateFontString(nil, "ARTWORK", "GameFontNormal")
appearanceTitle:SetPoint("TOPLEFT", 16, -244)
appearanceTitle:SetText("XP Bar Color")

local function MakeButton(label, x, y, width, onClick)
    local button = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
    button:SetSize(width, 22)
    button:SetPoint("TOPLEFT", x, y)
    button:SetText(label)
    button:SetScript("OnClick", onClick)
    return button
end

MakeButton("Purple (Forever)", 16, -266, 112, function() SetColor(PURPLE) end)
MakeButton("Blue (Classic)", 134, -266, 104, function() SetColor(BLUE) end)

local currentColorLabel = panel:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
currentColorLabel:SetPoint("TOPLEFT", 16, -302)
currentColorLabel:SetText("Current Color")

colorSwatch = CreateFrame("Button", nil, panel)
colorSwatch:SetSize(32, 22)
colorSwatch:SetPoint("LEFT", currentColorLabel, "RIGHT", 10, 0)
colorSwatch.texture = colorSwatch:CreateTexture(nil, "BACKGROUND")
colorSwatch.texture:SetAllPoints()
colorSwatch.border = colorSwatch:CreateTexture(nil, "BORDER")
colorSwatch.border:SetPoint("TOPLEFT", -2, 2)
colorSwatch.border:SetPoint("BOTTOMRIGHT", 2, -2)
colorSwatch.border:SetColorTexture(0.35, 0.35, 0.35, 1)

local customLabel = panel:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
customLabel:SetPoint("LEFT", colorSwatch, "RIGHT", 8, 0)
customLabel:SetText("Custom...")


local function OpenColorPicker()
    local old = CopyColor(Addon.db.xpColor)
    local function changed()
        local r, g, b = ColorPickerFrame:GetColorRGB()
        SetColor({ r = r, g = g, b = b })
    end
    local function cancelled(previous)
        if type(previous) == "table" and previous.r then
            SetColor(previous)
        else
            SetColor(old)
        end
    end

    if ColorPickerFrame.SetupColorPickerAndShow then
        ColorPickerFrame:SetupColorPickerAndShow({
            r = old.r, g = old.g, b = old.b,
            swatchFunc = changed,
            cancelFunc = cancelled,
            hasOpacity = false,
        })
    else
        ColorPickerFrame.hasOpacity = false
        ColorPickerFrame.previousValues = old
        ColorPickerFrame.func = changed
        ColorPickerFrame.cancelFunc = cancelled
        ColorPickerFrame:SetColorRGB(old.r, old.g, old.b)
        ColorPickerFrame:Show()
    end
end
colorSwatch:SetScript("OnClick", OpenColorPicker)
customLabel:SetScript("OnMouseDown", OpenColorPicker)
customLabel:EnableMouse(true)

local positionTitle = panel:CreateFontString(nil, "ARTWORK", "GameFontNormal")
positionTitle:SetPoint("TOPLEFT", 16, -344)
positionTitle:SetText("Position")

MakeCheckbox("Lock Position", "locked", -366)
MakeButton("Reset Position", 42, -398, 112, function()
    if Addon.ResetPosition then Addon.ResetPosition() end
end)

local defaultsButton = MakeButton("Defaults", 16, -444, 96, ResetDefaults)

panel:SetScript("OnShow", function()
    RefreshControls()
end)

local category = Compat.RegisterOptionsPanel(panel)

function Addon.OpenOptions()
    Compat.OpenOptionsPanel(panel, category)
end

Apply()
