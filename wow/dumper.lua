
SLASH_BRONZESCRAPE1 = "/bronzescrape-dump"

-- Raw talent dump for WotLK-era API (3.3.x).
-- Stores the result in a SavedVariables table (per-character) and also returns it.
--
-- TOC change required (per-character DB):
--   ## SavedVariablesPerCharacter: BronzeScrapeDB
--
-- Usage in-game:
--   /run BronzeScrape_DumpTalentsRaw()
-- Then log out (or /reload) to flush SavedVariables to disk.

BronzeScrapeDB = BronzeScrapeDB or {}

local function now_utc-ish()
  -- WoW Lua has date(); WotLK supports it. Keep it simple.
  return date("!%Y-%m-%dT%H:%M:%SZ")
end

function BronzeScrape_DumpTalentsRaw()
  local dump = {
    meta = {
      captured_at = now_utc-ish(),
      player = UnitName("player"),
      class = select(2, UnitClass("player")), -- e.g. "SHAMAN"
      level = UnitLevel("player"),
    },
    tabs = {},
  }

  local numTabs = GetNumTalentTabs(false, false) -- inspect=false, pet=false
  dump.meta.num_tabs = numTabs

  for tabIndex = 1, numTabs do
    -- name, iconTexture, pointsSpent, background, previewPointsSpent, isUnlocked
    local tabName, tabIcon, tabPoints, tabBg, tabPreviewPoints, tabUnlocked =
      GetTalentTabInfo(tabIndex, false, false)

    local tab = {
      tab_index = tabIndex,
      tab_info = { tabName, tabIcon, tabPoints, tabBg, tabPreviewPoints, tabUnlocked },
      talents = {},
    }

    local numTalents = GetNumTalents(tabIndex, false, false)
    tab.num_talents = numTalents

    for talentIndex = 1, numTalents do
      -- name, iconTexture, tier, column, currentRank, maxRank, isExceptional, meetsPrereq
      local name, icon, tier, column, curRank, maxRank, isExceptional, meetsPrereq =
        GetTalentInfo(tabIndex, talentIndex, false, false)

      -- prereqTier, prereqColumn, prereqTalentIndex (nil if none)
      local prereqTier, prereqColumn, prereqTalentIndex =
        GetTalentPrereqs(tabIndex, talentIndex, false, false)

      -- Talent link often includes spell ID info; keep it raw too (may be nil).
      local link = GetTalentLink(tabIndex, talentIndex, false, false)

      -- Tooltip text: optional; it’s “raw” but costs UI work. Keep it anyway.
      local tooltip
      if GameTooltip and GameTooltip.SetOwner and GameTooltip.SetTalent then
        GameTooltip:SetOwner(UIParent, "ANCHOR_NONE")
        GameTooltip:SetTalent(tabIndex, talentIndex)
        local lines = {}
        for i = 1, 30 do
          local left = _G["GameTooltipTextLeft" .. i]
          if not left then break end
          local text = left:GetText()
          if not text then break end
          lines[#lines + 1] = text
        end
        GameTooltip:Hide()
        tooltip = lines
      end

      -- “Ugly raw”: keep positional arrays for the WoW-returned tuples, plus extras.
      tab.talents[#tab.talents + 1] = {
        talent_index = talentIndex,
        info = { name, icon, tier, column, curRank, maxRank, isExceptional, meetsPrereq },
        prereqs = { prereqTier, prereqColumn, prereqTalentIndex },
        link = link,
        tooltip = tooltip,
      }
    end

    dump.tabs[#dump.tabs + 1] = tab
  end

  BronzeScrapeDB.raw_talents = dump
  BronzeScrapeDB.raw_talents_last_updated = dump.meta.captured_at

  DEFAULT_CHAT_FRAME:AddMessage("BronzeScrape: dumped raw talents to BronzeScrapeDB.raw_talents (logout or /reload to save).")
  return dump
end

SlashCmdList["BRONZESCRAPE"] = function(msg)
    msg = (msg or ""):lower()

    if msg == "talents" then
        BronzeScrape_DumpTalentsRaw()
        print("BronzeScrape: Exported talents to BronzeScrapeDB.talents")
    else
        print("BronzeScrape: Specify what to dump: talents")
    end
end