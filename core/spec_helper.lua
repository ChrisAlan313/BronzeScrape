-- spec_helper.lua
-- Ensure core directory is on package.path for tests
local root = debug.getinfo(1,'S').source:sub(2):match("(.*/)") or "./"
package.path = root .. "../?.lua;" .. package.path
