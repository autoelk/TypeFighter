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

CardFactory = {}
CardFactory.__index = CardFactory

function CardFactory:new()
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
        }
    }
    setmetatable(factory, self)
    return factory
end

function CardFactory:createCard(cardName, cardData)
    local CardClass = self.cardTypes[string.lower(cardName)]
    if CardClass then
        return CardClass:new(cardData)
    else
        -- Fallback to creating a generic card from the old system
        print("Warning: No specific class found for card '" .. cardName .. "', using BaseCard")
        cardData.name = cardName
        return BaseCard:new(cardData)
    end
end

function CardFactory:registerCardType(cardName, CardClass)
    self.cardTypes[string.lower(cardName)] = CardClass
end

-- Get all available card names
function CardFactory:getAllCardNames()
    local cardNames = {}
    for cardName, _ in pairs(self.cardTypes) do
        table.insert(cardNames, cardName)
    end
    table.sort(cardNames)
    return cardNames
end

-- Utility function to find a card by name in the GameManager's cards array
function CardFactory:findCard(cardToFind)
    cardToFind = string.lower(cardToFind)
    local cards = gameManager:getCards()
    for i = 1, #cards do
        if cards[i].name == cardToFind then
            return i
        end
    end
    return 0
end

-- Global instance
cardFactory = CardFactory:new()
