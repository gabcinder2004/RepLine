local ADDON, ns = ...

RepLine = RepLine or {}
local RL = RepLine

RL.MAX_BARS = 20
RL.FONT_PATH = "Interface\\AddOns\\RepLine\\media\\Inconsolata-Regular.ttf"

local DEFAULTS_DB = {
    point = "RIGHT",
    relPoint = "RIGHT",
    x = -16,
    y = 0,
    scale = 1.0,
    hidden = false,
    compact = false,
}

local DEFAULTS_CHAR = {
    watched = {},
}

local function ApplyDefaults(target, defaults)
    for k, v in pairs(defaults) do
        if target[k] == nil then
            if type(v) == "table" then
                target[k] = {}
                ApplyDefaults(target[k], v)
            else
                target[k] = v
            end
        end
    end
end

local previousValues = {}

function RL:IsWatched(factionID)
    for _, id in ipairs(RepLineCharDB.watched) do
        if id == factionID then return true end
    end
    return false
end

function RL:AddWatched(factionID)
    if self:IsWatched(factionID) then return end
    if #RepLineCharDB.watched >= self.MAX_BARS then return false end
    table.insert(RepLineCharDB.watched, factionID)
    return true
end

function RL:RemoveWatched(factionID)
    for i, id in ipairs(RepLineCharDB.watched) do
        if id == factionID then
            table.remove(RepLineCharDB.watched, i)
            previousValues[factionID] = nil
            return
        end
    end
end

function RL:GetWatchedList()
    return RepLineCharDB.watched
end

function RL:GetFactionData(factionID)
    local name, _, standingId, barMin, barMax, barValue, _, _, isHeader, _, hasRep =
        GetFactionInfoByID(factionID)
    if not name or isHeader and not hasRep then return nil end
    return {
        id = factionID,
        name = name,
        standingId = standingId,
        barMin = barMin or 0,
        barMax = barMax or 0,
        barValue = barValue or 0,
    }
end

function RL:EnumerateAllFactions()
    local out = {}
    local restoreList = {}
    local i = 1
    while i <= GetNumFactions() do
        local name, _, standingId, _, _, _, _, _, isHeader, isCollapsed, hasRep,
              _, _, factionID = GetFactionInfo(i)
        if isHeader and isCollapsed then
            restoreList[#restoreList + 1] = name
            ExpandFactionHeader(i)
        end
        if factionID and (not isHeader or hasRep) then
            out[#out + 1] = {
                id = factionID,
                name = name,
                standingId = standingId or 4,
            }
        end
        i = i + 1
    end
    if #restoreList > 0 then
        local restoreSet = {}
        for _, n in ipairs(restoreList) do restoreSet[n] = true end
        local total = GetNumFactions()
        for j = 1, total do
            local name, _, _, _, _, _, _, _, isHeader, isCollapsed = GetFactionInfo(j)
            if isHeader and not isCollapsed and restoreSet[name] then
                CollapseFactionHeader(j)
            end
        end
    end
    return out
end

local function OnUpdateFaction()
    if not RepLineCharDB or not RL.UI then return end
    local changed = {}
    for _, id in ipairs(RepLineCharDB.watched) do
        local data = RL:GetFactionData(id)
        if data then
            local prev = previousValues[id]
            if prev and data.barValue > prev then
                changed[id] = true
            end
            previousValues[id] = data.barValue
        end
    end
    RL.UI:Refresh(changed)
end

local f = CreateFrame("Frame")
f:RegisterEvent("ADDON_LOADED")
f:RegisterEvent("PLAYER_LOGIN")
f:RegisterEvent("UPDATE_FACTION")
f:SetScript("OnEvent", function(_, event, arg1)
    if event == "ADDON_LOADED" and arg1 == ADDON then
        RepLineDB = RepLineDB or {}
        RepLineCharDB = RepLineCharDB or {}
        ApplyDefaults(RepLineDB, DEFAULTS_DB)
        ApplyDefaults(RepLineCharDB, DEFAULTS_CHAR)
    elseif event == "PLAYER_LOGIN" then
        if RL.UI and RL.UI.Build then RL.UI:Build() end
        for _, id in ipairs(RepLineCharDB.watched) do
            local data = RL:GetFactionData(id)
            if data then previousValues[id] = data.barValue end
        end
        if RL.UI then RL.UI:Refresh({}) end
    elseif event == "UPDATE_FACTION" then
        OnUpdateFaction()
    end
end)

SLASH_REPLINE1 = "/rep"
SLASH_REPLINE2 = "/repline"
SlashCmdList["REPLINE"] = function(msg)
    msg = (msg or ""):lower():match("^%s*(.-)%s*$") or ""
    if msg == "debug" then
        print("|cff88ccffRepLine|r tracked factions:")
        for i, id in ipairs(RepLineCharDB.watched) do
            local data = RL:GetFactionData(id)
            if data then
                local label = _G["FACTION_STANDING_LABEL" .. (data.standingId or 4)] or "<nil>"
                print(string.format(
                    "  [%d] id=%d  name=%s  standingId=%s  label=%s  bar=%s/%s/%s",
                    i, id, tostring(data.name), tostring(data.standingId),
                    label, tostring(data.barValue), tostring(data.barMin), tostring(data.barMax)
                ))
            else
                print(string.format("  [%d] id=%d  <no data>", i, id))
            end
        end
        return
    end
    if not RL.UI then return end
    if msg == "edit" then
        RL.UI:ToggleEdit()
    elseif msg == "compact" then
        RL.UI:ToggleCompact()
    elseif msg == "reset" then
        RL.UI:ResetPosition()
    elseif msg == "show" then
        RL.UI:Show()
    elseif msg == "hide" then
        RL.UI:Hide()
    else
        RL.UI:Toggle()
    end
end
