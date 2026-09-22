local ADDON_NAME = ...
PetXPBarPlus = PetXPBarPlus or {}
local Addon = PetXPBarPlus

local Compat = {}
Addon.Compat = Compat

local _, _, _, interfaceVersion = GetBuildInfo()
Compat.interfaceVersion = tonumber(interfaceVersion) or 0
Compat.isForever = Compat.interfaceVersion >= 16000 and Compat.interfaceVersion < 17000

function Compat.GetLevelCap()
    if type(GetEffectivePlayerMaxLevel) == "function" then
        local ok, level = pcall(GetEffectivePlayerMaxLevel)
        if ok and type(level) == "number" then
            return level
        end
    end

    if type(GetMaxPlayerLevel) == "function" then
        local ok, level = pcall(GetMaxPlayerLevel)
        if ok and type(level) == "number" then
            return level
        end
    end

    return nil
end

function Compat.RegisterOptionsPanel(panel)
    if Settings and Settings.RegisterCanvasLayoutCategory and Settings.RegisterAddOnCategory then
        local category = Settings.RegisterCanvasLayoutCategory(panel, panel.name)
        Settings.RegisterAddOnCategory(category)
        return category
    end

    if InterfaceOptions_AddCategory then
        InterfaceOptions_AddCategory(panel)
    end

    return nil
end

function Compat.OpenOptionsPanel(panel, category)
    if category and Settings and Settings.OpenToCategory then
        Settings.OpenToCategory(category:GetID())
        return
    end

    if InterfaceOptionsFrame_OpenToCategory then
        -- The legacy UI commonly needs two calls to scroll/select correctly.
        InterfaceOptionsFrame_OpenToCategory(panel)
        InterfaceOptionsFrame_OpenToCategory(panel)
    end
end
