-- GryllsExpBar
local GryllsExpBar = CreateFrame("Frame", nil, UIParent)

GryllsExpBar_Settings = {
    barWidth = 465,
    barHeight = 18,    
    barLeft = 1075,
    barTop = 200,
    barBorder = true,
    darkTheme = false,
    classColor = false,
}

-- credit to Shagu (https://shagu.org/pfUI/) for code below
local function roundnum(input, places)
    if not places then places = 0 end
    if type(input) == "number" and type(places) == "number" then
        local pow = 1
        for i = 1, places do pow = pow * 10 end
        return floor(input * pow + 0.5) / pow
    end
end

local function createBar()
    -- local barTexture = "Interface/Tooltips/UI-Tooltip-Background"    
    local barTexture = "Interface/TargetingFrame/UI-StatusBar"

    -- (base layer to anchor other bars to)
    GryllsExpBar.backgroundBar = CreateFrame("StatusBar", nil, UIParent)
    GryllsExpBar.backgroundBar:SetFrameStrata("BACKGROUND")
    GryllsExpBar.backgroundBar:SetFrameLevel(0)  
    GryllsExpBar.backgroundBar:SetMovable(true)
    GryllsExpBar.backgroundBar:SetClampedToScreen()    

    GryllsExpBar.backgroundBar.bg = GryllsExpBar.backgroundBar:CreateTexture(nil, "BACKGROUND")
    GryllsExpBar.backgroundBar.bg:SetTexture(barTexture)
    GryllsExpBar.backgroundBar.bg:SetAllPoints(true)
    GryllsExpBar.backgroundBar.bg:SetVertexColor(0, 0, 0, 0.5)    
    
    GryllsExpBar.restedBar = CreateFrame("StatusBar", nil, GryllsExpBar.backgroundBar)       
    GryllsExpBar.restedBar:SetStatusBarTexture(barTexture)    
    GryllsExpBar.restedBar:SetFrameStrata("BACKGROUND")
    GryllsExpBar.restedBar:SetFrameLevel(1)
    GryllsExpBar.restedBar:SetAllPoints(GryllsExpBar.backgroundBar)

    GryllsExpBar.expBar = CreateFrame("StatusBar", nil, GryllsExpBar.backgroundBar)    
    GryllsExpBar.expBar:SetStatusBarTexture(barTexture)
    GryllsExpBar.expBar:SetFrameStrata("BACKGROUND")
    GryllsExpBar.expBar:SetFrameLevel(2)
    GryllsExpBar.expBar:SetAllPoints(GryllsExpBar.backgroundBar)    

    GryllsExpBar.repBar = CreateFrame("StatusBar", nil, GryllsExpBar.backgroundBar)       
    GryllsExpBar.repBar:SetStatusBarTexture(barTexture)
    GryllsExpBar.repBar:SetFrameStrata("BACKGROUND")
    GryllsExpBar.repBar:SetFrameLevel(3)
    GryllsExpBar.repBar:SetAllPoints(GryllsExpBar.backgroundBar)    

    GryllsExpBar.border = CreateFrame("Frame", nil, GryllsExpBar.backgroundBar)
    local p = 6
    GryllsExpBar.border:SetPoint("TOPLEFT", GryllsExpBar.backgroundBar, "TOPLEFT", -p, p)
    GryllsExpBar.border:SetPoint("BOTTOMRIGHT", GryllsExpBar.backgroundBar, "BOTTOMRIGHT", p, -p)
    GryllsExpBar.border:SetFrameStrata("BACKGROUND")
    GryllsExpBar.border:SetFrameLevel(4)

    local e, i = 19, 0
    GryllsExpBar.border:SetBackdrop(
        {        
            bgFile = "Interface/TargetingFrame/UI-StatusBar",
            edgeFile = "Interface/DialogFrame/UI-DialogBox-Border",
            tile = true, edgeSize = e, 
            insets = { left = i, right = i, top = i, bottom = i }
        }
    )        
    GryllsExpBar.border:SetBackdropBorderColor(1, 1, 1, 1)
    GryllsExpBar.border:SetBackdropColor(1,1,1,0)

    GryllsExpBar.string = CreateFrame("Frame", nil, GryllsExpBar.backgroundBar)
    GryllsExpBar.string:SetAllPoints(GryllsExpBar.backgroundBar)
    GryllsExpBar.string:SetFrameStrata("BACKGROUND")
    GryllsExpBar.string:SetFrameLevel(5)

    local font, size, outline = "Fonts\\frizqt__.TTF", 12, "OUTLINE"    
    GryllsExpBar.string.expText = GryllsExpBar.string:CreateFontString(nil, "OVERLAY", "GameFontWhite")
    GryllsExpBar.string.expText:SetFont(font, size, outline)
    GryllsExpBar.string.expText:SetPoint("CENTER", GryllsExpBar.string, "CENTER", 0, 1)
    GryllsExpBar.string.expText:Hide()

    GryllsExpBar.string.repText = GryllsExpBar.string:CreateFontString(nil, "OVERLAY", "GameFontWhite")
    GryllsExpBar.string.repText:SetFont(font, size, outline)
    GryllsExpBar.string.repText:SetAllPoints(GryllsExpBar.string.expText)
    GryllsExpBar.string.repText:Hide()

    GryllsExpBar.mouse = CreateFrame("Frame", nil, GryllsExpBar.backgroundBar)
    GryllsExpBar.mouse:SetAllPoints(GryllsExpBar.backgroundBar)
    GryllsExpBar.mouse:SetFrameStrata("BACKGROUND")
    GryllsExpBar.mouse:SetFrameLevel(5)
    GryllsExpBar.mouse:EnableMouse(true)
    GryllsExpBar.mouse:RegisterForDrag("LeftButton")
    
    GryllsExpBar.mouse:SetScript("OnEnter", function()
        local name = GetWatchedFactionInfo()
        if name then
            GryllsExpBar.string.expText:Hide()
            GryllsExpBar.string.repText:Show()
        else
            GryllsExpBar.string.repText:Hide()     
            GryllsExpBar.string.expText:Show()
        end
    end)

    GryllsExpBar.mouse:SetScript("OnLeave", function()
        GryllsExpBar.string.repText:Hide()
        GryllsExpBar.string.expText:Hide()
    end)    

    GryllsExpBar.mouse:SetScript("OnDragStart", function()
        if GryllsExpBar.move then
            GryllsExpBar.backgroundBar:StartMoving()
        end
    end)
    
    GryllsExpBar.mouse:SetScript("OnDragStop", function()
        GryllsExpBar.backgroundBar:StopMovingOrSizing()
        GryllsExpBar_Settings.barLeft = GryllsExpBar.backgroundBar:GetLeft()
        GryllsExpBar_Settings.barTop = GryllsExpBar.backgroundBar:GetTop()
        -- DEFAULT_CHAT_FRAME:AddMessage("Grylls|rExpBar: Left = "..GryllsExpBar_Settings.barLeft..", TOP = "..GryllsExpBar_Settings.barTop) -- debug
    end)
end

local function updateExp()
    local playerlevel = UnitLevel("player")
    -- credit to Shagu (https://shagu.org/pfUI/) for code below
    local function ExpText(xp, xpmax, exh, xp_perc, remaining, remaining_perc, playerlevel)    
        if playerlevel < 60 then
            if exh ~= 0 then        
                local exh_perc = roundnum(exh / xpmax * 100) or 0
                return "Level "..playerlevel.." - "..remaining.." ("..remaining_perc.."%) remaining - "..exh.." ("..exh_perc.."%) rested"
            else
                return "Level "..playerlevel.." - "..remaining.." ("..remaining_perc.."%) remaining"
            end
        end 
    end    

    local xp, xpmax, exh = UnitXP("player"), UnitXPMax("player"), GetXPExhaustion() or 0
    local xp_perc = roundnum(xp / xpmax * 100)
    local remaining = xpmax - xp
    local remaining_perc = roundnum(remaining / xpmax * 100)    

    -- set values for expBar
    GryllsExpBar.expBar:SetMinMaxValues(0, xpmax)
    GryllsExpBar.expBar:SetValue(xp)
    -- set values for rested
    GryllsExpBar.restedBar:SetMinMaxValues(0, xpmax)

    -- as you can rest into the next level...
    if exh > remaining then
        GryllsExpBar.restedBar:SetValue(xpmax) -- fill the restedBar as we have rested into the next level 
    else
        GryllsExpBar.restedBar:SetValue(xp + exh)
    end

    -- set color of bars
    local r,g,b = 0, 0.5, 1

    if GryllsExpBar_Settings.classColor then
        local _, class = UnitClass("player")
        local color = RAID_CLASS_COLORS[class]
        r,g,b = color.r, color.g, color.b
    end 
    
    GryllsExpBar.expBar:SetStatusBarColor(r,g,b,1)
    GryllsExpBar.restedBar:SetStatusBarColor(r,g,b,0.5) -- set alpha of rested bar

    -- set exp text       
    GryllsExpBar.string.expText:SetText(ExpText(xp, xpmax, exh, xp_perc, remaining, remaining_perc, playerlevel))
end

local function updateRep()
    local name, standing, min, max, value = GetWatchedFactionInfo()
    local max = max - min
    local value = value - min
    local remaining = max - value
    local percent = (value / max) * 100
    local percentFloor = floor(percent + 0.5)
    local repvalues = { "Hated", "Hostile", "Unfriendly", "Neutral", "Friendly", "Honored", "Revered", "Exalted" }
    local level = UnitLevel("player")

    if name then -- if we are watching a faction
        GryllsExpBar.repBar:Show()
        GryllsExpBar.expBar:SetValue(0) -- hide expBar
        GryllsExpBar.restedBar:SetValue(0) -- hide restedBar

        -- set rep values
        GryllsExpBar.repBar:SetMinMaxValues(0, max)
        GryllsExpBar.repBar:SetValue(value)

        -- set rep text
        GryllsExpBar.string.repText:SetText(name .. " (" .. repvalues[standing] .. ") " .. percentFloor .. "% - "  .. roundnum(remaining) .. " remaining")
        
        -- set rep colors
        local r = FACTION_BAR_COLORS[standing].r;
        local g = FACTION_BAR_COLORS[standing].g;
        local b = FACTION_BAR_COLORS[standing].b;
        GryllsExpBar.repBar:SetStatusBarColor(r,g,b,1)
        --GryllsExpBar.string.repText:Show()
    else 
        -- not watching a faction
        GryllsExpBar.repBar:Hide()
        updateExp(frame)        
        --GryllsExpBar.string.expText:Show()
    end
end

local function barBorder()
    local r,g,b = 1,1,1
    if GryllsExpBar_Settings.darkTheme == true then
        r,g,b = 0.3,0.3,0.3
    end
    GryllsExpBar.border:SetBackdropBorderColor(r, g, b, 1)

    if GryllsExpBar_Settings.barBorder then
        GryllsExpBar.border:Show()
    else
        GryllsExpBar.border:Hide()
    end
end

local function setBar()
    GryllsExpBar.backgroundBar:SetWidth(GryllsExpBar_Settings.barWidth)
    GryllsExpBar.backgroundBar:SetHeight(GryllsExpBar_Settings.barHeight)
    GryllsExpBar.backgroundBar:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", GryllsExpBar_Settings.barLeft, GryllsExpBar_Settings.barTop)
    barBorder()
end

local function resetBar()
    GryllsExpBar_Settings.barWidth = 465
    GryllsExpBar_Settings.barHeight = 18
    GryllsExpBar_Settings.barLeft = 1075
    GryllsExpBar_Settings.barTop = 200
    GryllsExpBar_Settings.barBorder = true
    GryllsExpBar_Settings.darkTheme = false
    GryllsExpBar_Settings.classColor = false
    setBar()
end

local function GryllsExpBar_commands(msg, editbox)
    local yellow = "FFFFFF00"
    local orange = "FFFF9900"

    local function fontnum(msg)
        local startPos = string.find(msg, "%d")
        local numstr = string.sub(msg, startPos)
        if tonumber(numstr) then
            return tonumber(numstr)
        else
            DEFAULT_CHAT_FRAME:AddMessage("Grylls|rExpBar: input was not a number, please try again")
        end
    end

    local num = nil
    if string.find(msg, "width %d") then
        num = fontnum(msg)
        GryllsExpBar_Settings.barWidth = num
        setBar()
        DEFAULT_CHAT_FRAME:AddMessage("|c"..orange.."Grylls|rExpBar: width set to "..num)
    elseif string.find(msg, "height %d") then
        num = fontnum(msg)
        GryllsExpBar_Settings.barHeight = num
        setBar()
        DEFAULT_CHAT_FRAME:AddMessage("|c"..orange.."Grylls|rExpBar: height set to "..num)    
    elseif msg == "border" then
        if GryllsExpBar_Settings.barBorder then
            GryllsExpBar_Settings.barBorder = false
            DEFAULT_CHAT_FRAME:AddMessage("|c"..orange.."Grylls|rExpBar: border hidden ")
        else
            GryllsExpBar_Settings.barBorder = true
            DEFAULT_CHAT_FRAME:AddMessage("|c"..orange.."Grylls|rExpBar: border shown ")
        end
        barBorder()
    elseif msg == "dark" then
        if GryllsExpBar_Settings.darkTheme then
            GryllsExpBar_Settings.darkTheme = false
            DEFAULT_CHAT_FRAME:AddMessage("|c"..orange.."Grylls|rExpBar: dark theme off")
        else
            GryllsExpBar_Settings.darkTheme = true
            DEFAULT_CHAT_FRAME:AddMessage("|c"..orange.."Grylls|rExpBar: dark theme on")
        end
        barBorder()
    elseif msg == "move" then
        if GryllsExpBar.move then
            GryllsExpBar.move = false
            DEFAULT_CHAT_FRAME:AddMessage("|c"..orange.."Grylls|rExpBar: bar locked")
        else
            GryllsExpBar.move = true
            DEFAULT_CHAT_FRAME:AddMessage("|c"..orange.."Grylls|rExpBar: bar unlocked")
        end
        barBorder()
    elseif msg == "class" then
        if GryllsExpBar_Settings.classColor then
            GryllsExpBar_Settings.classColor = false
            DEFAULT_CHAT_FRAME:AddMessage("|c"..orange.."Grylls|rExpBar: class coloring off")
        else
            GryllsExpBar_Settings.classColor = true
            DEFAULT_CHAT_FRAME:AddMessage("|c"..orange.."Grylls|rExpBar: class coloring on")
        end
        updateExp()
    elseif msg == "reset" then
        resetBar()
        DEFAULT_CHAT_FRAME:AddMessage("|c"..orange.."Grylls|rExpBar: exp bar has been reset")
    else
        DEFAULT_CHAT_FRAME:AddMessage("|c"..orange.."Grylls|rExpBar usage:")
        DEFAULT_CHAT_FRAME:AddMessage("|c"..yellow.."/geb move |r - toggle allowing moving of the bar by dragging it")   
        DEFAULT_CHAT_FRAME:AddMessage("|c"..yellow.."/geb width n|r - set bar to width n")
        DEFAULT_CHAT_FRAME:AddMessage("|c"..yellow.."/geb height n|r - set bar to height n")
        DEFAULT_CHAT_FRAME:AddMessage("|c"..yellow.."/geb border |r - toggle bar border")
        DEFAULT_CHAT_FRAME:AddMessage("|c"..yellow.."/geb dark |r - toggle dark theme border")
        DEFAULT_CHAT_FRAME:AddMessage("|c"..yellow.."/geb class |r - toggle class coloring of exp bar")  
        DEFAULT_CHAT_FRAME:AddMessage("|c"..yellow.."/geb reset |r - reset bar to default settings")             
    end
end

GryllsExpBar:RegisterEvent("ADDON_LOADED")
GryllsExpBar:RegisterEvent("PLAYER_ENTERING_WORLD")
GryllsExpBar:RegisterEvent("PLAYER_XP_UPDATE")
GryllsExpBar:RegisterEvent("UPDATE_FACTION")
GryllsExpBar:SetScript("OnEvent", function()
	if event == "ADDON_LOADED" then
		if not GryllsExpBar.loaded then
            SLASH_GRYLLSEXPBAR1 = "/gryllsexpbar"
            SLASH_GRYLLSEXPBAR2 = "/geb"
            SlashCmdList["GRYLLSEXPBAR"] = GryllsExpBar_commands

			createBar()
            setBar()

			DEFAULT_CHAT_FRAME:AddMessage("|cffff8000Grylls|rGryllsExpBar loaded! /geb")
            GryllsExpBar.move = false
            GryllsExpBar.loaded = true
		end
    elseif event == "PLAYER_ENTERING_WORLD" then
        updateExp()
        updateRep()
    elseif event == "PLAYER_XP_UPDATE" then
        updateExp()
    elseif event == "UPDATE_FACTION" then   
        updateRep()
    end
end)