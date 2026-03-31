require "cards.BaseCard"
require "cards.FireballCard"
require "cards.HealCard"
require "cards.BoltCard"
require "cards.TorrentCard"
require "cards.PoisonCard"
require "cards.RageCard"
require "cards.BlessingCard"
require "cards.TyphoonCard"
require "cards.PunchCard"
require "cards.SliceCard"
require "cards.PortalCard"
require "cards.ForceFieldCard"

-- Static class responsible for creating card instances based on their names
CardManager = {}
CardManager.__index = CardManager

function CardManager:new(ctx)
    if not ctx then
        error("CardManager:new(ctx) requires ctx")
    end
    local manager = {
        ctx = ctx,
        cardTypes = {
            ["fireball"] = FireballCard,
            ["heal"] = HealCard,
            ["bolt"] = BoltCard,
            ["torrent"] = TorrentCard,
            ["poison"] = PoisonCard,
            ["rage"] = RageCard,
            ["blessing"] = BlessingCard,
            ["typhoon"] = TyphoonCard,
            ["punch"] = PunchCard,
            ["slice"] = SliceCard,
            ["portal"] = PortalCard,
            ["forcefield"] = ForceFieldCard
        },
        cardNames = {}
    }
    for cardName, _ in pairs(manager.cardTypes) do
        table.insert(manager.cardNames, cardName)
    end
    
    return setmetatable(manager, self)
end

function CardManager:createCard(cardName)
    local CardClass = self.cardTypes[string.lower(cardName)]
    if CardClass then
        return CardClass:new(self.ctx, 0, 0)
    else
        error("Unknown card type: " .. tostring(cardName))
    end
end

function CardManager:getAllCardNames()
    return self.cardNames
end
