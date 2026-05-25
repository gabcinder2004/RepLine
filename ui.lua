local RL = RepLine
local UI = {}
RL.UI = UI

local PANEL_WIDTH      = 260
local PANEL_PAD_X      = 14
local PANEL_PAD_Y      = 10
local HEADER_H         = 16
local BAR_HEIGHT       = 34
local BAR_GAP          = 6
local COMPACT_BAR_HEIGHT = 18
local COMPACT_BAR_GAP    = 3
local ACCENT_WIDTH     = 3
local PROGRESS_HEIGHT  = 2
local FILL_LERP_SPEED  = 8

local C_NAME           = { 0.84, 0.82, 0.78 }
local C_DETAIL         = { 0.84, 0.82, 0.78, 0.60 }
local C_PERCENT        = { 0.84, 0.82, 0.78, 0.70 }
local C_PANEL_BG       = { 0.031, 0.031, 0.039, 0.85 }
local C_HAIRLINE       = { 1, 1, 1, 0.04 }
local C_PROGRESS_BG    = { 1, 1, 1, 0.08 }
local C_HINT           = { 0.84, 0.82, 0.78, 0.30 }

local function SafeSetFont(fs, size, flags)
    local ok = fs:SetFont(RL.FONT_PATH, size, flags or "")
    if not ok then
        fs:SetFont(STANDARD_TEXT_FONT, size, flags or "")
    end
end

local STANDING_ABBREV = {
    [1] = "H",  -- Hated      (color disambiguates: red)
    [2] = "H",  -- Hostile    (color disambiguates: orange)
    [3] = "U",  -- Unfriendly
    [4] = "N",  -- Neutral
    [5] = "F",  -- Friendly
    [6] = "H",  -- Honored    (color disambiguates: turquoise)
    [7] = "R",  -- Revered
    [8] = "E",  -- Exalted
}

local STANDING_COLORS = {
    [1] = { 0.855, 0.282, 0.282 },  -- Hated      red          #DA4848
    [2] = { 0.871, 0.494, 0.220 },  -- Hostile    orange       #DE7E38
    [3] = { 0.878, 0.722, 0.220 },  -- Unfriendly amber/gold   #E0B838
    [4] = { 0.667, 0.639, 0.604 },  -- Neutral    warm taupe   #AAA39A
    [5] = { 0.345, 0.816, 0.322 },  -- Friendly   bright green #58D052
    [6] = { 0.122, 0.812, 0.753 },  -- Honored    turquoise    #1FCFC0
    [7] = { 0.302, 0.490, 0.929 },  -- Revered    royal blue   #4D7DED
    [8] = { 0.788, 0.357, 0.937 },  -- Exalted    magenta      #C95BEF
}

local function StandingColor(standingId)
    local c = STANDING_COLORS[standingId or 4]
    if c then return c[1], c[2], c[3] end
    return 0.5, 0.5, 0.5
end

local function StandingLabel(standingId)
    standingId = standingId or 4
    local key = "FACTION_STANDING_LABEL" .. standingId
    local sex = UnitSex and UnitSex("player") or 1
    local label
    if GetText then label = GetText(key, sex) end
    if not label or label == "" then label = _G[key] end
    if not label or label == "" then label = "Unknown" end
    return label
end

local function FormatNumber(n)
    if not n then return "—" end
    if n >= 1000 then
        return string.format("%d,%03d", math.floor(n / 1000), n % 1000)
    end
    return tostring(n)
end

local panel
local bars = {}
local editFrame

local function LayoutBar(bar, compact)
    bar.accent:ClearAllPoints()
    bar.name:ClearAllPoints()
    bar.percent:ClearAllPoints()
    bar.progressBg:ClearAllPoints()
    bar.progressFill:ClearAllPoints()
    bar.detail:ClearAllPoints()
    bar.letter:ClearAllPoints()

    if compact then
        local h = COMPACT_BAR_HEIGHT
        bar:SetHeight(h)

        bar.accent:SetSize(ACCENT_WIDTH, h)
        bar.accent:SetPoint("TOPLEFT", 0, 0)

        bar.progressBg:SetHeight(h)
        bar.progressBg:SetPoint("TOPLEFT", bar.accent, "TOPRIGHT", 2, 0)
        bar.progressBg:SetPoint("BOTTOMRIGHT", bar, "BOTTOMRIGHT", 0, 0)

        bar.progressFill:SetHeight(h)
        bar.progressFill:SetPoint("TOPLEFT", bar.progressBg, "TOPLEFT", 0, 0)

        bar.letter:SetFont(STANDARD_TEXT_FONT, 12, "OUTLINE")
        bar.letter:SetPoint("LEFT", bar.progressBg, "LEFT", 5, 0)
        bar.letter:SetWidth(14)
        bar.letter:Show()

        bar.name:SetFont(STANDARD_TEXT_FONT, 11, "OUTLINE")
        bar.name:SetPoint("LEFT", bar.letter, "RIGHT", 6, 0)
        bar.name:SetPoint("RIGHT", bar.progressBg, "RIGHT", -42, 0)
        bar.name:SetShadowOffset(0, 0)

        bar.percent:SetFont(STANDARD_TEXT_FONT, 11, "OUTLINE")
        bar.percent:SetPoint("RIGHT", bar.progressBg, "RIGHT", -6, 0)
        bar.percent:SetWidth(36)
        bar.percent:SetShadowOffset(0, 0)

        bar.detail:Hide()
    else
        local h = BAR_HEIGHT
        bar:SetHeight(h)

        bar.accent:SetSize(ACCENT_WIDTH, h)
        bar.accent:SetPoint("TOPLEFT", 0, 0)

        bar.name:SetFont(STANDARD_TEXT_FONT, 11, "OUTLINE")
        bar.name:SetPoint("TOPLEFT", bar.accent, "TOPRIGHT", 10, -1)
        bar.name:SetPoint("TOPRIGHT", bar, "TOPRIGHT", -52, -1)
        bar.name:SetShadowOffset(0, 0)

        bar.percent:SetFont(STANDARD_TEXT_FONT, 11, "OUTLINE")
        bar.percent:SetPoint("TOPRIGHT", bar, "TOPRIGHT", -2, -1)
        bar.percent:SetWidth(48)
        bar.percent:SetShadowOffset(0, 0)

        bar.progressBg:SetHeight(PROGRESS_HEIGHT)
        bar.progressBg:SetPoint("TOPLEFT", bar.accent, "TOPRIGHT", 10, -15)
        bar.progressBg:SetPoint("RIGHT", bar, "RIGHT", -2, 0)

        bar.progressFill:SetHeight(PROGRESS_HEIGHT)
        bar.progressFill:SetPoint("TOPLEFT", bar.progressBg, "TOPLEFT", 0, 0)

        bar.detail:SetFont(STANDARD_TEXT_FONT, 10, "OUTLINE")
        bar.detail:SetPoint("TOPLEFT", bar.progressBg, "BOTTOMLEFT", 0, -3)
        bar.detail:SetPoint("TOPRIGHT", bar.progressBg, "BOTTOMRIGHT", 0, -3)
        bar.detail:Show()

        bar.letter:Hide()
    end
end

local function CreateBar(parent, index)
    local bar = CreateFrame("Frame", nil, parent)
    bar:SetWidth(PANEL_WIDTH - PANEL_PAD_X * 2)

    bar.accent = bar:CreateTexture(nil, "ARTWORK")
    bar.accent:SetColorTexture(0.5, 0.5, 0.5, 1)

    bar.name = bar:CreateFontString(nil, "OVERLAY")
    SafeSetFont(bar.name, 11)
    bar.name:SetTextColor(unpack(C_NAME))
    bar.name:SetJustifyH("LEFT")
    bar.name:SetWordWrap(false)

    bar.percent = bar:CreateFontString(nil, "OVERLAY")
    SafeSetFont(bar.percent, 11)
    bar.percent:SetTextColor(unpack(C_PERCENT))
    bar.percent:SetJustifyH("RIGHT")

    bar.progressBg = bar:CreateTexture(nil, "ARTWORK")
    bar.progressBg:SetColorTexture(unpack(C_PROGRESS_BG))

    bar.progressFill = bar:CreateTexture(nil, "OVERLAY")
    bar.progressFill:SetColorTexture(0.5, 0.5, 0.5, 1)
    bar.progressFill:SetWidth(0)

    bar.detail = bar:CreateFontString(nil, "OVERLAY")
    SafeSetFont(bar.detail, 10)
    bar.detail:SetTextColor(unpack(C_DETAIL))
    bar.detail:SetJustifyH("LEFT")
    bar.detail:SetWordWrap(false)

    bar.letter = bar:CreateFontString(nil, "OVERLAY")
    bar.letter:SetFont(STANDARD_TEXT_FONT, 12, "OUTLINE")
    bar.letter:SetJustifyH("CENTER")
    bar.letter:SetWordWrap(false)

    LayoutBar(bar, false)

    local pulse = bar.accent:CreateAnimationGroup()
    local dim = pulse:CreateAnimation("Alpha")
    dim:SetFromAlpha(1.0); dim:SetToAlpha(0.25); dim:SetDuration(0.12); dim:SetOrder(1)
    local rise = pulse:CreateAnimation("Alpha")
    rise:SetFromAlpha(0.25); rise:SetToAlpha(1.0); rise:SetDuration(0.45); rise:SetOrder(2)
    bar.pulse = pulse

    bar.currentWidth = 0
    bar.targetWidth = 0
    bar:Hide()
    return bar
end

local function SetBarData(bar, data, maxFillWidth)
    if not data then
        bar.name:SetText("")
        bar.percent:SetText("")
        bar.detail:SetText("")
        bar.letter:SetText("")
        bar.progressFill:SetWidth(0)
        bar.targetWidth = 0
        bar.currentWidth = 0
        return
    end
    local r, g, b = StandingColor(data.standingId)
    local fillAlpha = (RepLineDB and RepLineDB.compact) and 0.65 or 1.0
    bar.accent:SetColorTexture(r, g, b, 1)
    bar.progressFill:SetColorTexture(r, g, b, fillAlpha)

    bar.letter:SetText(STANDING_ABBREV[data.standingId or 4] or "?")
    bar.letter:SetTextColor(1, 1, 1, 1)

    bar.name:SetText(data.name)

    local span = (data.barMax or 0) - (data.barMin or 0)
    local cur = (data.barValue or 0) - (data.barMin or 0)
    local pct = 0
    if span > 0 then pct = math.max(0, math.min(1, cur / span)) end

    bar.percent:SetText(string.format("%d%%", math.floor(pct * 100 + 0.5)))

    if span > 0 then
        bar.detail:SetText(string.format(
            "%s  \194\183  %s / %s",
            StandingLabel(data.standingId),
            FormatNumber(cur),
            FormatNumber(span)
        ))
    else
        bar.detail:SetText(string.format("%s  \194\183  Maxed", StandingLabel(data.standingId)))
    end

    bar.targetWidth = pct * maxFillWidth
end

local function PanelOnUpdate(self, elapsed)
    for _, bar in ipairs(bars) do
        if bar:IsShown() then
            local diff = bar.targetWidth - bar.currentWidth
            if math.abs(diff) > 0.1 then
                bar.currentWidth = bar.currentWidth + diff * math.min(1, elapsed * FILL_LERP_SPEED)
                bar.progressFill:SetWidth(math.max(0, bar.currentWidth))
            elseif bar.currentWidth ~= bar.targetWidth then
                bar.currentWidth = bar.targetWidth
                bar.progressFill:SetWidth(math.max(0, bar.targetWidth))
            end
        end
    end
end

local function RestorePosition()
    panel:ClearAllPoints()
    panel:SetPoint(
        RepLineDB.point or "RIGHT",
        UIParent,
        RepLineDB.relPoint or "RIGHT",
        RepLineDB.x or -16,
        RepLineDB.y or 0
    )
    panel:SetScale(RepLineDB.scale or 1.0)
end

local function SavePosition()
    local point, _, relPoint, x, y = panel:GetPoint()
    RepLineDB.point = point
    RepLineDB.relPoint = relPoint
    RepLineDB.x = x
    RepLineDB.y = y
end

-- Control icons ------------------------------------------------------------

local CONTROL_DIM    = { 0.84, 0.82, 0.78, 0.4 }
local CONTROL_BRIGHT = { 1, 1, 1, 1 }

-- 12x12 clickable icon for the top control row. `draw(btn)` builds the glyph
-- textures and returns a recolor function used for the dim<->bright hover.
local function CreateIconButton(parent, onClick, draw)
    local btn = CreateFrame("Frame", nil, parent)
    btn:SetSize(12, 12)
    btn:SetFrameLevel(parent:GetFrameLevel() + 10)
    btn:EnableMouse(true)
    local setColor = draw(btn)
    setColor(unpack(CONTROL_DIM))
    btn:SetScript("OnEnter", function() setColor(unpack(CONTROL_BRIGHT)) end)
    btn:SetScript("OnLeave", function() setColor(unpack(CONTROL_DIM)) end)
    btn:SetScript("OnMouseUp", function(_, button)
        if button == "LeftButton" then onClick() end
    end)
    return btn
end

local function DrawCompactGlyph(btn)
    local line = btn:CreateTexture(nil, "OVERLAY")
    line:SetSize(7, 1)
    line:SetPoint("CENTER")
    return function(r, g, b, a) line:SetColorTexture(r, g, b, a) end
end

local function DrawCloseGlyph(btn)
    local x1 = btn:CreateTexture(nil, "OVERLAY")
    x1:SetSize(10, 1)
    x1:SetPoint("CENTER")
    x1:SetRotation(math.rad(45))
    local x2 = btn:CreateTexture(nil, "OVERLAY")
    x2:SetSize(10, 1)
    x2:SetPoint("CENTER")
    x2:SetRotation(math.rad(-45))
    return function(r, g, b, a)
        x1:SetColorTexture(r, g, b, a)
        x2:SetColorTexture(r, g, b, a)
    end
end

local function DrawOptionsGlyph(btn)
    local lines = {}
    for i = 1, 3 do
        local t = btn:CreateTexture(nil, "OVERLAY")
        t:SetSize(8, 1)
        t:SetPoint("CENTER", btn, "CENTER", 0, (i - 2) * 3)  -- +3, 0, -3
        lines[i] = t
    end
    return function(r, g, b, a)
        for _, t in ipairs(lines) do t:SetColorTexture(r, g, b, a) end
    end
end

function UI:Build()
    if panel then return end

    panel = CreateFrame("Frame", "RepLineFrame", UIParent)
    panel:SetSize(PANEL_WIDTH, 56)
    panel:SetFrameStrata("MEDIUM")
    panel:SetClampedToScreen(true)
    panel:EnableMouse(true)
    panel:SetMovable(true)
    panel:RegisterForDrag("LeftButton")

    panel.bg = panel:CreateTexture(nil, "BACKGROUND")
    panel.bg:SetAllPoints()
    panel.bg:SetColorTexture(unpack(C_PANEL_BG))

    panel.topLine = panel:CreateTexture(nil, "BORDER")
    panel.topLine:SetHeight(1)
    panel.topLine:SetPoint("TOPLEFT", 0, 0)
    panel.topLine:SetPoint("TOPRIGHT", 0, 0)
    panel.topLine:SetColorTexture(unpack(C_HAIRLINE))

    panel.bottomLine = panel:CreateTexture(nil, "BORDER")
    panel.bottomLine:SetHeight(1)
    panel.bottomLine:SetPoint("BOTTOMLEFT", 0, 0)
    panel.bottomLine:SetPoint("BOTTOMRIGHT", 0, 0)
    panel.bottomLine:SetColorTexture(unpack(C_HAIRLINE))

    panel.hint = panel:CreateFontString(nil, "OVERLAY")
    SafeSetFont(panel.hint, 10)
    panel.hint:SetTextColor(unpack(C_HINT))
    panel.hint:SetPoint("CENTER")
    panel.hint:SetText("RIGHT-CLICK TO ADD FACTIONS")
    panel.hint:Hide()

    panel:SetScript("OnDragStart", function(self) self:StartMoving() end)
    panel:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        SavePosition()
    end)
    panel:SetScript("OnMouseUp", function(_, button)
        if button == "RightButton" then UI:ToggleEdit() end
    end)
    panel:SetScript("OnUpdate", PanelOnUpdate)

    -- Top-right control row: options (menu) | compact | close
    local closeBtn = CreateIconButton(panel, function() UI:Hide() end, DrawCloseGlyph)
    closeBtn:SetPoint("TOPRIGHT", panel, "TOPRIGHT", -6, -3)

    local compactBtn = CreateIconButton(panel, function() UI:ToggleCompact() end, DrawCompactGlyph)
    compactBtn:SetPoint("RIGHT", closeBtn, "LEFT", -8, 0)

    local optionsBtn = CreateIconButton(panel, function() UI:ToggleOptions() end, DrawOptionsGlyph)
    optionsBtn:SetPoint("RIGHT", compactBtn, "LEFT", -8, 0)

    panel.closeBtn = closeBtn
    panel.compactBtn = compactBtn
    panel.optionsBtn = optionsBtn

    UI.inCombat = InCombatLockdown() and true or false

    for i = 1, RL.MAX_BARS do
        bars[i] = CreateBar(panel, i)
    end

    RestorePosition()

    if RepLineDB.hidden then
        panel:Hide()
    end
end

function UI:Refresh(changedSet)
    if not panel then return end
    changedSet = changedSet or {}

    local watched = RL:GetOrderedWatched()
    local compact = RepLineDB.compact and true or false
    local barHeight = compact and COMPACT_BAR_HEIGHT or BAR_HEIGHT
    local barGap = compact and COMPACT_BAR_GAP or BAR_GAP

    local innerWidth = PANEL_WIDTH - PANEL_PAD_X * 2
    local maxFillWidth
    if compact then
        maxFillWidth = innerWidth - ACCENT_WIDTH - 2
    else
        maxFillWidth = innerWidth - (ACCENT_WIDTH + 10) - 2
    end

    local count = 0
    for i, factionID in ipairs(watched) do
        if i > RL.MAX_BARS then break end
        local bar = bars[i]
        LayoutBar(bar, compact)
        local data = RL:GetFactionData(factionID)
        SetBarData(bar, data, maxFillWidth)
        bar:ClearAllPoints()
        local yOffset = -HEADER_H - (i - 1) * (barHeight + barGap)
        bar:SetPoint("TOPLEFT", panel, "TOPLEFT", PANEL_PAD_X, yOffset)
        bar:SetPoint("TOPRIGHT", panel, "TOPRIGHT", -PANEL_PAD_X, yOffset)
        bar:Show()
        if changedSet[factionID] and bar.pulse then
            bar.pulse:Stop()
            bar.pulse:Play()
        end
        count = i
    end
    for i = count + 1, RL.MAX_BARS do
        bars[i]:Hide()
    end

    local panelHeight
    if count == 0 then
        panelHeight = 56
        panel.hint:Show()
    else
        panelHeight = HEADER_H + PANEL_PAD_Y + count * barHeight + (count - 1) * barGap
        panel.hint:Hide()
    end
    panel:SetHeight(panelHeight)
end

function UI:ToggleCompact()
    RepLineDB.compact = not RepLineDB.compact
    self:Refresh({})
end

function UI:Toggle()
    if not panel then return end
    if panel:IsShown() then
        panel:Hide()
        RepLineDB.hidden = true
    else
        panel:Show()
        RepLineDB.hidden = false
    end
    self.combatHidden = false
end

function UI:Show()
    if not panel then return end
    panel:Show()
    RepLineDB.hidden = false
    self.combatHidden = false
end

function UI:Hide()
    if not panel then return end
    panel:Hide()
    RepLineDB.hidden = true
    self.combatHidden = false
end

-- Combat auto-hide ----------------------------------------------------------

function UI:OnCombat(entering)
    self.inCombat = entering and true or false
    self:ApplyCombatState()
end

-- Hides the panel for the duration of combat when "hide in combat" is on,
-- without disturbing the manual hidden state. An explicit /rep show or the
-- ✕ button (which clear combatHidden) takes precedence for the current fight.
function UI:ApplyCombatState()
    if not panel then return end
    if RepLineDB.hidden then return end  -- manual hide takes precedence
    if RepLineDB.hideInCombat and self.inCombat then
        if panel:IsShown() then
            panel:Hide()
            self.combatHidden = true
        end
    elseif self.combatHidden then
        panel:Show()
        self.combatHidden = false
    end
end

function UI:ResetPosition()
    if not panel then return end
    RepLineDB.point = "RIGHT"
    RepLineDB.relPoint = "RIGHT"
    RepLineDB.x = -16
    RepLineDB.y = 0
    RestorePosition()
end

-- Edit mode -----------------------------------------------------------------

local EDIT_WIDTH       = 340
local EDIT_HEIGHT      = 460
local ROW_HEIGHT       = 24
local editRows = {}

local function CreateEditRow(parent, index)
    local row = CreateFrame("Frame", nil, parent)
    row:SetSize(EDIT_WIDTH - 32, ROW_HEIGHT)
    row:EnableMouse(true)

    row.hover = row:CreateTexture(nil, "BACKGROUND")
    row.hover:SetAllPoints()
    row.hover:SetColorTexture(1, 1, 1, 0.05)
    row.hover:Hide()

    row.dot = row:CreateTexture(nil, "ARTWORK")
    row.dot:SetSize(6, 6)
    row.dot:SetPoint("LEFT", 4, 0)

    row.name = row:CreateFontString(nil, "OVERLAY")
    row.name:SetFont(STANDARD_TEXT_FONT, 11, "OUTLINE")
    row.name:SetTextColor(unpack(C_NAME))
    row.name:SetJustifyH("LEFT")
    row.name:SetPoint("LEFT", row.dot, "RIGHT", 10, 0)
    row.name:SetPoint("RIGHT", row, "RIGHT", -130, 0)

    row.standing = row:CreateFontString(nil, "OVERLAY")
    row.standing:SetFont(STANDARD_TEXT_FONT, 10, "OUTLINE")
    row.standing:SetTextColor(unpack(C_DETAIL))
    row.standing:SetJustifyH("RIGHT")
    row.standing:SetPoint("RIGHT", row, "RIGHT", -28, 0)
    row.standing:SetWidth(96)

    row.box = CreateFrame("Frame", nil, row)
    row.box:SetSize(12, 12)
    row.box:SetPoint("RIGHT", row, "RIGHT", -4, 0)

    row.boxBg = row.box:CreateTexture(nil, "ARTWORK")
    row.boxBg:SetAllPoints()
    row.boxBg:SetColorTexture(1, 1, 1, 0.10)

    row.boxFill = row.box:CreateTexture(nil, "OVERLAY")
    row.boxFill:SetPoint("TOPLEFT", 2, -2)
    row.boxFill:SetPoint("BOTTOMRIGHT", -2, 2)
    row.boxFill:SetColorTexture(0.84, 0.82, 0.78, 1)
    row.boxFill:Hide()

    row:SetScript("OnEnter", function(self) self.hover:Show() end)
    row:SetScript("OnLeave", function(self) self.hover:Hide() end)
    row:SetScript("OnMouseUp", function(self)
        if not self.factionID then return end
        if RL:IsWatched(self.factionID) then
            RL:RemoveWatched(self.factionID)
            self.boxFill:Hide()
        else
            local ok = RL:AddWatched(self.factionID)
            if ok then
                self.boxFill:Show()
            else
                UIErrorsFrame:AddMessage(
                    "RepLine: watchlist full (max " .. RL.MAX_BARS .. ")",
                    1.0, 0.3, 0.3
                )
            end
        end
        UI:Refresh({})
    end)

    return row
end

local function BuildEditFrame()
    editFrame = CreateFrame("Frame", "RepLineEditFrame", UIParent)
    editFrame:SetSize(EDIT_WIDTH, EDIT_HEIGHT)
    editFrame:SetPoint("CENTER")
    editFrame:SetFrameStrata("DIALOG")
    editFrame:EnableMouse(true)
    editFrame:SetMovable(true)
    editFrame:RegisterForDrag("LeftButton")
    editFrame:SetScript("OnDragStart", function(self) self:StartMoving() end)
    editFrame:SetScript("OnDragStop", function(self) self:StopMovingOrSizing() end)
    editFrame:Hide()

    editFrame.bg = editFrame:CreateTexture(nil, "BACKGROUND")
    editFrame.bg:SetAllPoints()
    editFrame.bg:SetColorTexture(unpack(C_PANEL_BG))

    editFrame.topLine = editFrame:CreateTexture(nil, "BORDER")
    editFrame.topLine:SetHeight(1)
    editFrame.topLine:SetPoint("TOPLEFT", 0, 0)
    editFrame.topLine:SetPoint("TOPRIGHT", 0, 0)
    editFrame.topLine:SetColorTexture(unpack(C_HAIRLINE))

    editFrame.bottomLine = editFrame:CreateTexture(nil, "BORDER")
    editFrame.bottomLine:SetHeight(1)
    editFrame.bottomLine:SetPoint("BOTTOMLEFT", 0, 0)
    editFrame.bottomLine:SetPoint("BOTTOMRIGHT", 0, 0)
    editFrame.bottomLine:SetColorTexture(unpack(C_HAIRLINE))

    editFrame.title = editFrame:CreateFontString(nil, "OVERLAY")
    editFrame.title:SetFont(STANDARD_TEXT_FONT, 12, "OUTLINE")
    editFrame.title:SetTextColor(unpack(C_NAME))
    editFrame.title:SetPoint("TOPLEFT", 16, -14)
    editFrame.title:SetText("EDIT WATCHLIST")

    editFrame.subtitle = editFrame:CreateFontString(nil, "OVERLAY")
    editFrame.subtitle:SetFont(STANDARD_TEXT_FONT, 10, "OUTLINE")
    editFrame.subtitle:SetTextColor(unpack(C_DETAIL))
    editFrame.subtitle:SetPoint("TOPLEFT", 16, -30)

    local close = CreateFrame("Frame", nil, editFrame)
    close:SetSize(14, 14)
    close:SetPoint("TOPRIGHT", -14, -14)
    close:EnableMouse(true)
    local cx1 = close:CreateTexture(nil, "ARTWORK")
    cx1:SetSize(14, 1)
    cx1:SetPoint("CENTER")
    cx1:SetColorTexture(0.84, 0.82, 0.78, 0.8)
    cx1:SetRotation(math.rad(45))
    local cx2 = close:CreateTexture(nil, "ARTWORK")
    cx2:SetSize(14, 1)
    cx2:SetPoint("CENTER")
    cx2:SetColorTexture(0.84, 0.82, 0.78, 0.8)
    cx2:SetRotation(math.rad(-45))
    close:SetScript("OnMouseUp", function() editFrame:Hide() end)
    close:SetScript("OnEnter", function()
        cx1:SetColorTexture(1, 1, 1, 1); cx2:SetColorTexture(1, 1, 1, 1)
    end)
    close:SetScript("OnLeave", function()
        cx1:SetColorTexture(0.84, 0.82, 0.78, 0.8)
        cx2:SetColorTexture(0.84, 0.82, 0.78, 0.8)
    end)

    local scroll = CreateFrame("ScrollFrame", "RepLineEditScroll", editFrame, "UIPanelScrollFrameTemplate")
    scroll:SetPoint("TOPLEFT", 16, -52)
    scroll:SetPoint("BOTTOMRIGHT", -28, 16)

    local content = CreateFrame("Frame", nil, scroll)
    content:SetSize(EDIT_WIDTH - 44, 1)
    scroll:SetScrollChild(content)
    editFrame.scroll = scroll
    editFrame.content = content
end

local function PopulateEditRows()
    local list = RL:EnumerateAllFactions()
    table.sort(list, function(a, b) return (a.name or "") < (b.name or "") end)

    for i = #list + 1, #editRows do
        editRows[i]:Hide()
    end

    for i, item in ipairs(list) do
        local row = editRows[i]
        if not row then
            row = CreateEditRow(editFrame.content, i)
            editRows[i] = row
        end
        row.factionID = item.id
        row:ClearAllPoints()
        row:SetPoint("TOPLEFT", editFrame.content, "TOPLEFT", 0, -(i - 1) * ROW_HEIGHT)
        row:SetPoint("TOPRIGHT", editFrame.content, "TOPRIGHT", 0, -(i - 1) * ROW_HEIGHT)

        local r, g, b = StandingColor(item.standingId)
        row.dot:SetColorTexture(r, g, b, 1)
        row.name:SetText(item.name or "")
        row.standing:SetText(StandingLabel(item.standingId))
        if RL:IsWatched(item.id) then
            row.boxFill:Show()
        else
            row.boxFill:Hide()
        end
        row:Show()
    end

    editFrame.content:SetHeight(math.max(1, #list * ROW_HEIGHT))
    editFrame.subtitle:SetText(string.format(
        "%d FACTIONS  \194\183  %d / %d TRACKED",
        #list, #RL:GetWatchedList(), RL.MAX_BARS
    ))
end

function UI:ToggleEdit()
    if not editFrame then BuildEditFrame() end
    if editFrame:IsShown() then
        editFrame:Hide()
    else
        PopulateEditRows()
        editFrame:Show()
    end
end

-- Options -------------------------------------------------------------------

local OPT_WIDTH  = 300
local OPT_HEIGHT = 210
local OPT_ROW_H  = 24
local optionsFrame
local sortRows = {}

local SORT_MODES = {
    { key = "manual",   label = "Watchlist order" },
    { key = "name",     label = "Name (A-Z)" },
    { key = "rep_desc", label = "Reputation (high to low)" },
    { key = "rep_asc",  label = "Reputation (low to high)" },
}

-- Small square indicator reused for the checkbox and the sort selection.
local function MakeCheckBox(parent)
    local box = CreateFrame("Frame", nil, parent)
    box:SetSize(12, 12)
    box.bg = box:CreateTexture(nil, "ARTWORK")
    box.bg:SetAllPoints()
    box.bg:SetColorTexture(1, 1, 1, 0.10)
    box.fill = box:CreateTexture(nil, "OVERLAY")
    box.fill:SetPoint("TOPLEFT", 2, -2)
    box.fill:SetPoint("BOTTOMRIGHT", -2, 2)
    box.fill:SetColorTexture(0.84, 0.82, 0.78, 1)
    box.fill:Hide()
    return box
end

local function MakeOptionRow(parent, yTop)
    local row = CreateFrame("Frame", nil, parent)
    row:SetPoint("TOPLEFT", 16, yTop)
    row:SetPoint("TOPRIGHT", -16, yTop)
    row:SetHeight(OPT_ROW_H)
    row:EnableMouse(true)
    row.hover = row:CreateTexture(nil, "BACKGROUND")
    row.hover:SetAllPoints()
    row.hover:SetColorTexture(1, 1, 1, 0.05)
    row.hover:Hide()
    row.label = row:CreateFontString(nil, "OVERLAY")
    row.label:SetFont(STANDARD_TEXT_FONT, 11, "OUTLINE")
    row.label:SetTextColor(unpack(C_NAME))
    row.label:SetJustifyH("LEFT")
    row:SetScript("OnEnter", function(self) self.hover:Show() end)
    row:SetScript("OnLeave", function(self) self.hover:Hide() end)
    return row
end

local function BuildOptionsFrame()
    optionsFrame = CreateFrame("Frame", "RepLineOptionsFrame", UIParent)
    optionsFrame:SetSize(OPT_WIDTH, OPT_HEIGHT)
    optionsFrame:SetPoint("CENTER")
    optionsFrame:SetFrameStrata("DIALOG")
    optionsFrame:EnableMouse(true)
    optionsFrame:SetMovable(true)
    optionsFrame:RegisterForDrag("LeftButton")
    optionsFrame:SetScript("OnDragStart", function(self) self:StartMoving() end)
    optionsFrame:SetScript("OnDragStop", function(self) self:StopMovingOrSizing() end)
    optionsFrame:Hide()

    optionsFrame.bg = optionsFrame:CreateTexture(nil, "BACKGROUND")
    optionsFrame.bg:SetAllPoints()
    optionsFrame.bg:SetColorTexture(unpack(C_PANEL_BG))

    optionsFrame.topLine = optionsFrame:CreateTexture(nil, "BORDER")
    optionsFrame.topLine:SetHeight(1)
    optionsFrame.topLine:SetPoint("TOPLEFT", 0, 0)
    optionsFrame.topLine:SetPoint("TOPRIGHT", 0, 0)
    optionsFrame.topLine:SetColorTexture(unpack(C_HAIRLINE))

    optionsFrame.bottomLine = optionsFrame:CreateTexture(nil, "BORDER")
    optionsFrame.bottomLine:SetHeight(1)
    optionsFrame.bottomLine:SetPoint("BOTTOMLEFT", 0, 0)
    optionsFrame.bottomLine:SetPoint("BOTTOMRIGHT", 0, 0)
    optionsFrame.bottomLine:SetColorTexture(unpack(C_HAIRLINE))

    optionsFrame.title = optionsFrame:CreateFontString(nil, "OVERLAY")
    optionsFrame.title:SetFont(STANDARD_TEXT_FONT, 12, "OUTLINE")
    optionsFrame.title:SetTextColor(unpack(C_NAME))
    optionsFrame.title:SetPoint("TOPLEFT", 16, -14)
    optionsFrame.title:SetText("OPTIONS")

    local close = CreateFrame("Frame", nil, optionsFrame)
    close:SetSize(14, 14)
    close:SetPoint("TOPRIGHT", -14, -14)
    close:EnableMouse(true)
    local cx1 = close:CreateTexture(nil, "ARTWORK")
    cx1:SetSize(14, 1)
    cx1:SetPoint("CENTER")
    cx1:SetColorTexture(0.84, 0.82, 0.78, 0.8)
    cx1:SetRotation(math.rad(45))
    local cx2 = close:CreateTexture(nil, "ARTWORK")
    cx2:SetSize(14, 1)
    cx2:SetPoint("CENTER")
    cx2:SetColorTexture(0.84, 0.82, 0.78, 0.8)
    cx2:SetRotation(math.rad(-45))
    close:SetScript("OnMouseUp", function() optionsFrame:Hide() end)
    close:SetScript("OnEnter", function()
        cx1:SetColorTexture(1, 1, 1, 1); cx2:SetColorTexture(1, 1, 1, 1)
    end)
    close:SetScript("OnLeave", function()
        cx1:SetColorTexture(0.84, 0.82, 0.78, 0.8)
        cx2:SetColorTexture(0.84, 0.82, 0.78, 0.8)
    end)

    -- Hide in combat (checkbox row)
    local hic = MakeOptionRow(optionsFrame, -44)
    hic.label:SetPoint("LEFT", 4, 0)
    hic.label:SetText("Hide in combat")
    hic.box = MakeCheckBox(hic)
    hic.box:SetPoint("RIGHT", -4, 0)
    hic:SetScript("OnMouseUp", function(self)
        RepLineDB.hideInCombat = not RepLineDB.hideInCombat
        if RepLineDB.hideInCombat then self.box.fill:Show() else self.box.fill:Hide() end
        UI:ApplyCombatState()
    end)
    -- preserve the hover handlers from MakeOptionRow
    optionsFrame.hideInCombat = hic

    -- Sort section
    optionsFrame.sortHeader = optionsFrame:CreateFontString(nil, "OVERLAY")
    optionsFrame.sortHeader:SetFont(STANDARD_TEXT_FONT, 10, "OUTLINE")
    optionsFrame.sortHeader:SetTextColor(unpack(C_DETAIL))
    optionsFrame.sortHeader:SetPoint("TOPLEFT", 16, -44 - OPT_ROW_H - 10)
    optionsFrame.sortHeader:SetText("SORT ORDER")

    local sortTop = -44 - OPT_ROW_H - 10 - 16
    for i, mode in ipairs(SORT_MODES) do
        local row = MakeOptionRow(optionsFrame, sortTop - (i - 1) * OPT_ROW_H)
        row.dot = MakeCheckBox(row)
        row.dot:SetPoint("LEFT", 4, 0)
        row.label:SetPoint("LEFT", row.dot, "RIGHT", 10, 0)
        row.label:SetText(mode.label)
        row.modeKey = mode.key
        row:SetScript("OnMouseUp", function(self)
            RepLineDB.sort = self.modeKey
            for _, r in ipairs(sortRows) do
                if r.modeKey == RepLineDB.sort then r.dot.fill:Show() else r.dot.fill:Hide() end
            end
            UI:Refresh({})
        end)
        sortRows[i] = row
    end
end

local function PopulateOptions()
    if RepLineDB.hideInCombat then
        optionsFrame.hideInCombat.box.fill:Show()
    else
        optionsFrame.hideInCombat.box.fill:Hide()
    end
    local current = RepLineDB.sort or "manual"
    for _, r in ipairs(sortRows) do
        if r.modeKey == current then r.dot.fill:Show() else r.dot.fill:Hide() end
    end
end

function UI:ToggleOptions()
    if not optionsFrame then BuildOptionsFrame() end
    if optionsFrame:IsShown() then
        optionsFrame:Hide()
    else
        PopulateOptions()
        optionsFrame:Show()
        if UIFrameFadeIn then UIFrameFadeIn(optionsFrame, 0.12, 0, 1) end
    end
end
