require "cards.BaseCard"
require "cards.FireballCard"
require "cards.HealCard"
require "cards.GemCard"
require "cards.BoltCard"
require "cards.TorrentCard"
require "cards.RitualCard"
require "cards.PoisonCard"
require "cards.RageCard"
require "cards.BlessingCard"
require "cards.TyphoonCard"
require "cards.PunchCard"
require "cards.ManatideCard"
require "cards.ForceCard"
require "cards.SliceCard"
require "cards.PortalCard"

-- Static class responsible for creating card instances based on their names
CardManager = {}
CardManager.__index = CardManager

function CardManager:new()
    local factory = {
        cardTypes = {
            ["fireball"] = FireballCard,
            ["heal"] = HealCard,
            ["gem"] = GemCard,
            ["bolt"] = BoltCard,
            ["torrent"] = TorrentCard,
            ["ritual"] = RitualCard,
            ["poison"] = PoisonCard,
            ["rage"] = RageCard,
            ["blessing"] = BlessingCard,
            ["typhoon"] = TyphoonCard,
            ["punch"] = PunchCard,
            ["manatide"] = ManatideCard,
            ["force"] = ForceCard,
            ["slice"] = SliceCard,
            ["portal"] = PortalCard
        },
        cardNames = {}
    }
    for cardName, _ in pairs(factory.cardTypes) do
        table.insert(factory.cardNames, cardName)
    end
    setmetatable(factory, self)
    return factory
end

function CardManager:createCard(cardName)
    local CardClass = self.cardTypes[string.lower(cardName)]
    if CardClass then
        return CardClass:new(0, 0)
    else
        error("Unknown card type: " .. tostring(cardName))
    end
end

function CardManager:getAllCardNames()
    return self.cardNames
end
