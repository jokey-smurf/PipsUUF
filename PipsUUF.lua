local addonName, ns = ...

local PIP_WIDTH = 2           -- Width of each pip
local PIP_LAST_WIDTH = 5      -- Width of the last pip
local PIP_COLOR = { 1, 1, 1 } -- Color of each pip
local PIP_ALPHA = 1           -- Alpha of each pip

-- Addon name
local function AddonName(color)
    local color = color or "00FF00"
    return string.format("|cff%s%s|r", color, addonName)
end

local function Msg(msg, value)
    value = value or ""
    print(AddonName() .. ": " .. msg .. " " .. value)
end

local _version = C_AddOns.GetAddOnMetadata(addonName, "Version") or ""
Msg("Version", version)

local def = C_AddOns.GetAddOnMetadata('UnhaltedUnitFrames', 'X-oUF') or "OOPS"
local oUF = _G[def]
if not oUF then
    Msg("ERROR: Unhalted Unit Frames/oUF not found")
    return
end

local function IsEmpoweredSpellCast()
    local _, _, _, _, _, _, _, _, isEmpowered, numEmpowerStages = UnitChannelInfo('player')
    return isEmpowered, numEmpowerStages
end

local function CreatePip(element, stage)
    -- Msg("CreatePip ", stage)
    local texture = element:CreateTexture(nil, 'OVERLAY', 'CastingBarFrameStagePipTemplate', 1)
    texture:SetParent(element)
    local height = element:GetHeight() * 0.9
    texture:SetSize(PIP_WIDTH, height)
    local r, g, b = unpack(PIP_COLOR)
    texture:SetColorTexture(r, g, b, PIP_ALPHA) -- (stage == element.lastStage) and 0 or PIP_ALPHA)

    return texture
end

local function PostUpdatePips(castbar)
    if not castbar.Pips then return end
    local isEmpowered, stageCount = IsEmpoweredSpellCast()
    if not isEmpowered then
        return
    end
    -- Msg("StageCount", stageCount)
    for i = 1, stageCount + 1 do
        -- local castbar = playerFrame.Castbar
        local pip = castbar.Pips[i] -- GetPip(playerFrame.Castbar, i)
        if not pip then return end

        -- make the last empowered pip bigger
        pip:SetSize((i == stageCount) and PIP_LAST_WIDTH or PIP_WIDTH, pip:GetHeight())
        -- ouf shows the pip at the end of the castbar, hide it
        pip:SetShown(i ~= stageCount + 1)
    end
end

-- our pip manipulation setup
local function SetPipHook(frame)
    local castbar = frame.Castbar
    if not castbar then
        return
    end
    if castbar.hooked then
        return
    end

    castbar.hooked = true
    castbar.PostUpdatePips = PostUpdatePips -- called after all pips displayed
    castbar.CreatePip = CreatePip           -- called to create a pip (only once per pip per castbar)
end

-- Hook oUF spawn to look at each frame
hooksecurefunc(oUF, "Spawn", function(frameOrUnit, unitOrStyle)
    -- print("PIP: Spawn")
    C_Timer.After(1, function()
        -- Scan all oUF objects to find the one just created, a bit superfulous, but atan
        -- least its only at startup
        for _, frame in ipairs(oUF.objects) do
            -- Msg(frame.style)
            if frame.style and frame.style == "UUF_Player" and not frame.hooked then
                -- Msg("Hooked player frame")
                frame.hooked = true
                SetPipHook(frame)

                -- Hook EnableElement for the player frame in case a castbar gets added later
                -- Only needed for toggling on and off the castbar
                hooksecurefunc(getmetatable(frame).__index, "EnableElement", function(frame, element)
                    -- print("PIP: Enabled Element callled" .. element)
                    if element == "Castbar" and frame.Castbar and not frame.Castbar.hooked then
                        -- The castbar was just added to an existing frame
                        -- Msg("Delayed castbar found")
                        -- Perhaps C_Timer.After(0.5, function() SetPipHook(frame) end)
                        SetPipHook(frame)
                    end
                end)
            end
        end
    end)
end)

SLASH_PIPSUUF1 = "/pips"
SlashCmdList["PIPSUUF"] = function(msg)
    Msg("Version", _version)
end
