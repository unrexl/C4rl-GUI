-- C4RL GUI LIBRARY v2.0 - Enhanced Edition
-- Professional GUI Framework for Roblox
-- Usage: local C4RL = loadstring(game:HttpGet("YOUR_URL"))()

local C4RLLib = {}

-- Base URLs for modules
local BASE_URL = "https://raw.githubusercontent.com/unrexl/C4rl-GUI/main/"

-- Module URLs
local MODULES = {
    Themes = BASE_URL .. "Themes.lua",
    Utils = BASE_URL .. "Utils.lua",
    WindowManager = BASE_URL .. "WindowManager.lua",
    InteractiveElements = BASE_URL .. "InteractiveElements.lua",
    AdvancedElements = BASE_URL .. "AdvancedElements.lua",
    ConfigAndNotifications = BASE_URL .. "ConfigAndNotifications.lua"
}

-- Load modules
local function LoadModule(url)
    local success, result = pcall(function()
        return loadstring(game:HttpGet(url))()
    end)
    
    if not success then
        warn("Failed to load module from: " .. url)
        warn("Error: " .. tostring(result))
        return nil
    end
    
    return result
end

print("[C4RL] Loading modules...")

local Themes = LoadModule(MODULES.Themes)
local Utils = LoadModule(MODULES.Utils)
local WindowManager = LoadModule(MODULES.WindowManager)
local InteractiveElements = LoadModule(MODULES.InteractiveElements)
local AdvancedElements = LoadModule(MODULES.AdvancedElements)
local ConfigAndNotifications = LoadModule(MODULES.ConfigAndNotifications)

-- Verify all modules loaded
if not (Themes and Utils and WindowManager and InteractiveElements and AdvancedElements and ConfigAndNotifications) then
    error("[C4RL] Failed to load one or more required modules!")
end

print("[C4RL] All modules loaded successfully!")

-- Main constructor
function C4RLLib.new(options)
    options = options or {}
    
    -- Create the library instance with WindowManager
    local Library = WindowManager.Create(options, Themes, Utils)
    
    -- Inject all element methods into Library
    InteractiveElements.Inject(Library, Utils)
    AdvancedElements.Inject(Library, Utils)
    ConfigAndNotifications.Inject(Library, Utils)
    
    return Library
end

return C4RLLib
