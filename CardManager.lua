require "cards.BaseCard"

require "cards.vampire.SwipeCard"
require "cards.vampire.ShroudCard"
require "cards.vampire.LacerateCard"
require "cards.vampire.RageCard"
require "cards.vampire.SliceCard"
require "cards.vampire.SiphonCard"

require "cards.wizard.BoltCard"
require "cards.wizard.ForceFieldCard"
require "cards.wizard.FireballCard"
require "cards.wizard.HealCard"
require "cards.wizard.TorrentCard"
require "cards.wizard.BlessingCard"
require "cards.wizard.PortalCard"
require "cards.wizard.GemCard"

-- Static class responsible for creating card instances based on their names
CardManager = {}
CardManager.__index = CardManager

function CardManager:new(ctx)
    if not ctx then
        error("CardManager:new(ctx) requires ctx")
    end
    local manager = {
        ctx = ctx,
        -- Map of card name to card class
        cardTypes = {
            ["swipe"] = SwipeCard,
            ["shroud"] = ShroudCard,
            ["lacerate"] = LacerateCard,
            ["rage"] = RageCard,
            ["siphon"] = SiphonCard,
            ["slice"] = SliceCard,
   
            ["fireball"] = FireballCard,
            ["bolt"] = BoltCard,
            ["forcefield"] = ForceFieldCard,
            ["heal"] = HealCard,
            ["torrent"] = TorrentCard,
            ["blessing"] = BlessingCard,
            ["portal"] = PortalCard,
            ["gem"] = GemCard,
        },
        cardCharacters = {}, -- Map of card name to character name
        cardNames = {} -- List of card names
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

function CardManager:getRandomCards(count, characterName)
    local cards = {}
    for cardName, cardCharacter in pairs(self.cardCharacters) do
        if cardCharacter == characterName then
            table.insert(cards, cardName)
        end
    end

    local randomCards = {}
    for i = 1, count do
        local cardIdx = math.random(1, #cards)
        local cardClass = self.cardTypes[cards[cardIdx]]
        table.remove(cards, cardIdx)
        table.insert(randomCards, cardClass:new(self.ctx, 0, 0))
    end
    return randomCards
end