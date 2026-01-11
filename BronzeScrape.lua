--[[
I've removed all the AI generated code to approach this with sanity and
intention.
]]

--[[
This file is for wiring the `core` functions which are not related to the WoW
API and the `wow` functions which are related to the WoW API.
]]

-- core/schema.lua and wow/dumper.lua are loaded via the .toc file
-- They expose globals (e.g. SCHEMA_VERSION, BronzeScrape_DumpTalentsRaw)

-- luacheck: globals SLASH_BRONZESCRAPE1 SlashCmdList BronzeScrape_DumpTalentsRaw DEFAULT_CHAT_FRAME

DEFAULT_CHAT_FRAME:AddMessage("BronzeScrape: BronzeScrape.lua loaded")

SLASH_BRONZESCRAPE1 = "/bronzescrape-dump"

SlashCmdList["BRONZESCRAPE"] = function(msg)
    msg = (msg or ""):lower()

    if msg == "talents" then
        BronzeScrape_DumpTalentsRaw()
        print("BronzeScrape: Exported talents to BronzeScrapeDB.talents")
    else
        print("BronzeScrape: Specify what to dump: talents")
    end
end