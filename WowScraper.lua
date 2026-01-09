BronzeScrapeDB = BronzeScrapeDB or {}

local function DumpTable(o)
    if type(o) == 'table' then
        local s = '{ '
        for k,v in pairs(o) do
            if type(k) ~= 'number' then k = '"'..k..'"' end
            s = s .. '['..k..'] = ' .. DumpTable(v) .. ','
        end
        return s .. '} '
    else
        return tostring(o)
    end
end

local ExportFrame = CreateFrame("Frame", "BronzeExportFrame", UIParent)
ExportFrame:SetFrameStrata("DIALOG")
ExportFrame:SetAllPoints(UIParent)
ExportFrame:Hide()

ExportFrame:SetBackdrop({
    bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
    edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
    tile = true,
    tileSize = 32,
    edgeSize = 32,
    insets = { left = 8, right = 8, top = 8, bottom = 8 }
})


local Scroll = CreateFrame("ScrollFrame", "BronzeExportScroll", ExportFrame, "UIPanelScrollFrameTemplate")
Scroll:SetPoint("TOPLEFT", 16, -16)
Scroll:SetPoint("BOTTOMRIGHT", -36, 16)


local EditBox = CreateFrame("EditBox", "BronzeExportEditBox", Scroll)
EditBox:SetMultiLine(true)
EditBox:SetFontObject(ChatFontNormal)
EditBox:SetWidth(GetScreenWidth() - 80)
EditBox:SetAutoFocus(false)
EditBox:EnableMouse(true)
EditBox:SetTextInsets(8, 8, 8, 8)

Scroll:SetScrollChild(EditBox)

local EditBox = CreateFrame("EditBox", "BronzeExportEditBox", Scroll)
EditBox:SetMultiLine(true)
EditBox:SetFontObject(ChatFontNormal)
EditBox:SetWidth(GetScreenWidth() - 80)
EditBox:SetAutoFocus(false)
EditBox:EnableMouse(true)
EditBox:SetTextInsets(8, 8, 8, 8)

Scroll:SetScrollChild(EditBox)


EditBox:SetScript("OnEscapePressed", function()
    ExportFrame:Hide()
end)


function Bronze_ShowExport(text)
    ExportFrame:Show()
    EditBox:SetText(text or "")
    EditBox:HighlightText(0)
    EditBox:SetFocus()
end


local function TableToString(t, indent)
    indent = indent or ""
    local str = ""
    for k, v in pairs(t) do
        if type(v) == "table" then
            str = str .. indent .. k .. ":\n" .. TableToString(v, indent .. "  ")
        else
            str = str .. indent .. k .. ": " .. tostring(v) .. "\n"
        end
    end
    return str
end

local function TooltipToLines(tooltip)
    local lines = {}
    for i = 1, 30 do
        local left = _G[tooltip:GetName() .. "TextLeft" .. i]
        local right = _G[tooltip:GetName() .. "TextRight" .. i]
        local ltxt = left and left:GetText()
        local rtxt = right and right:GetText()

        if ltxt and ltxt ~= "" then
            if rtxt and rtxt ~= "" then
                table.insert(lines, ltxt .. " || " .. rtxt)
            else
                table.insert(lines, ltxt)
            end
        end
    end
    return lines
end

local function ExportTalents()
    BronzeScrapeDB.talents = {}
    local out = BronzeScrapeDB.talents

    local numTabs = GetNumTalentTabs()
    for tab = 1, numTabs do
        local name, iconTexture, pointsSpent, fileName = GetTalentTabInfo(tab)

        out[tab] = {
            tabIndex = tab,
            name = name,
            fileName = fileName,
            pointsSpent = pointsSpent,
            talents = {}
        }

        local numTalents = GetNumTalents(tab)
        for t = 1, numTalents do
            local tName, tIcon, tier, column, currentRank, maxRank = GetTalentInfo(tab, t)
            if tName then
                GameTooltip:ClearLines()
                GameTooltip:SetTalent(tab, t)
                local tipLines = TooltipToLines(GameTooltip)

                table.insert(out[tab].talents, {
                    talentIndex = t,
                    name = tName,
                    tier = tier,
                    column = column,
                    currentRank = currentRank,
                    maxRank = maxRank,
                    tooltip = tipLines
                })
            end
        end
    end
end

local function ExportSpellbook()
    BronzeScrapeDB.spells = {}
    local out = BronzeScrapeDB.spells

    local numTabs = GetNumSpellTabs()
    for tab = 1, numTabs do
        local name, texture, offset, numSpells = GetSpellTabInfo(tab)
        out[tab] = { tabIndex = tab, name = name, spells = {} }

        for i = offset + 1, offset + numSpells do
            local spellType, spellID = GetSpellBookItemInfo(i, BOOKTYPE_SPELL)
            if spellType == "SPELL" then
                GameTooltip:ClearLines()
                GameTooltip:SetSpellBookItem(i, BOOKTYPE_SPELL)
                local tipLines = TooltipToLines(GameTooltip)

                local sName, sRank, sIcon = GetSpellBookItemName(i, BOOKTYPE_SPELL)
                table.insert(out[tab].spells, {
                    slot = i,
                    spellID = spellID,
                    name = sName,
                    rank = sRank,
                    tooltip = tipLines
                })
            end
        end
    end
end

SLASH_BRONZESCRAPE1 = "/bscrape"
SlashCmdList["BRONZESCRAPE"] = function(msg)
    msg = (msg or ""):lower()

    if msg == "talents" then
        ExportTalents()
        Bronze_ShowExport(TableToString(BronzeScrapeDB.talents))
        print("BronzeScrape: Exported talents to BronzeScrapeDB.talents")
    elseif msg == "spells" then
        ExportSpellbook()
        Bronze_ShowExport(TableToString(BronzeScrapeDB.spells))
        print("BronzeScrape: Exported spellbook to BronzeScrapeDB.spells")
    else
        ExportTalents()
        ExportSpellbook()
        Bronze_ShowExport(TableToString(BronzeScrapeDB))
        print("BronzeScrape: Exported talents + spells.")
    end
    print("Log out to write SavedVariables, then copy from WTF/.../SavedVariables/BronzeScrape.lua")
end

local f = CreateFrame("Frame", "BronzeScrapeFrame", UIParent)
f:SetSize(700, 500)
f:SetPoint("CENTER")
f:SetBackdrop({
    bgFile="Interface\\DialogFrame\\UI-DialogBox-Background",
    edgeFile="Interface\\DialogFrame\\UI-DialogBox-Border",
    tile=true, tileSize=32, edgeSize=32,
    insets={left=8,right=8,top=8,bottom=8}
})
f:Hide()

local sf = CreateFrame("ScrollFrame", "BronzeScrapeScroll", f, "UIPanelScrollFrameTemplate")
sf:SetPoint("TOPLEFT", 16, -16)
sf:SetPoint("BOTTOMRIGHT", -36, 16)

local eb = CreateFrame("EditBox", "BronzeScrapeEditBox", sf)
eb:SetMultiLine(true)
eb:SetFontObject(ChatFontNormal)
eb:SetWidth(640)
eb:SetAutoFocus(false)
eb:EnableMouse(true)

sf:SetScrollChild(eb)

local function ShowExport(text)
    f:Show()
    eb:SetText(text or "")
    eb:HighlightText(0)
end
