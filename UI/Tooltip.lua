-- Skillwright - the lines Skillwright adds to an item tooltip: what the auction house wants for it,
-- and - for an enchanter - what disenchanting items like it has actually given.
-- Deliberately small. A price is the thing you want to know while the cursor is over an item; anything
-- more belongs in the guide. Where the price comes from is part of the price: a number from Auctionator
-- and a number from a scan you ran last Tuesday are not the same claim, and they do not look the same.
-- No price, no line. An empty "unknown" is worse than silence.
local ADDON, SW = ...

local Pr = SW.Prices

-- Item ids can be secret values on Forever; comparing or formatting one throws.
local isSecret = issecretvalue or function() return false end

-- What to call the source, and how old it is when that is the interesting part.
local function SourceLabel(key)
    if key == "auctionator" then return "Auctionator" end
    if key == "tsm" then return "TSM" end
    local t = SW.DB().ahScanned or 0
    return t > 0 and ("your scan, " .. Pr.Ago(t)) or "your scan"
end

--- The line to add, or nil. Split out so the offline tests can read it without a tooltip.
--- Returns text, plus true when the price is too old for the guide to plan with.
function SW.TooltipPriceLine(id)
    if not id or isSecret(id) then return nil end
    if not SW.Settings().tooltipPrice then return nil end

    local price, source = Pr.Market(id)
    if price then
        return ("|cffffd100Auction|r %s |cff8a8a8a(%s)|r"):format(SW.MoneyShort(price), SourceLabel(source))
    end

    -- Nothing fresh. We may still have a scanned price the guide has stopped trusting: worth seeing,
    -- as long as it says so itself. The whole line goes grey, so it never reads like a current price.
    local e = SW.DB().ah[id]
    if e and e[1] and e[1] > 0 and e[2] then
        return ("|cff8a8a8aAuction %s (your scan, %s - too old for the guide)|r")
            :format(SW.MoneyPlain(e[1]), Pr.Ago(e[2])), true
    end
end

if TooltipDataProcessor and TooltipDataProcessor.AddTooltipPostCall and Enum and Enum.TooltipDataType then
    TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Item, function(tt, data)
        if tt ~= GameTooltip and tt ~= ItemRefTooltip then return end
        local id = data and data.id
        if not id or isSecret(id) then return end
        local line = SW.TooltipPriceLine(id)
        if line then tt:AddLine(line) end
        -- Only an enchanter ever sees this one, and only for an item that disenchants.
        local de = SW.Disenchant and SW.Disenchant.Line(id)
        if de then tt:AddLine(de) end
    end)
end
