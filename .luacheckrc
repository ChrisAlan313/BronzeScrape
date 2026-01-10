-- Luacheck configuration tuned for World of Warcraft addons (Lua 5.1)
std = "lua51"

files = {
  "BronzeScrape.lua",
  "core/**.lua",
  "wow/**.lua",
}

globals = {
  -- Common WoW API globals
  "CreateFrame", "GetAddOnMetadata", "GetAddOnInfo", "InterfaceOptions_AddCategory",
  "GetPlayerInfoByGUID", "C_Timer", "UnitName", "UnitClass", "IsAddOnLoaded",
  -- Common libraries
  "LibStub", "AceGUI", "AceGUIWidget-CheckBox",
}

exclude_files = { "vendor/**", "libs/**" }

-- Allow unused variables that start with underscore
allow_unused_args = true
