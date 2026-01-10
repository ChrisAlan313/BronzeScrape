-- Luacheck configuration tuned for World of Warcraft addons (Lua 5.1)
std = "lua51"

files = {
  "BronzeScrape.lua",
  "core/**.lua",
  "wow/**.lua",
}

globals = {
-- Will be filled as required
}

exclude_files = { "vendor/**", "libs/**" }

-- May be changed to true later.
allow_unused_args = false
