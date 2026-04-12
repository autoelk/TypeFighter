require "cards.BaseCard"

require "cards.vampire.SwipeCard"
require "cards.vampire.ShroudCard"
require "cards.vampire.LacerateCard"
require "cards.vampire.RageCard"
require "cards.vampire.SliceCard"
require "cards.vampire.SiphonCard"
require "cards.vampire.CoagulateCard"
require "cards.vampire.BloodPactCard"

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
            ["coagulate"] = CoagulateCard,
            ["bloodpact"] = BloodPactCard,
   
            ["fireball"] = FireballCard,
            ["bolt"] = BoltCard,
            ["forcefield"] = ForceFieldCard,
            ["heal"] = HealCard,
            ["torrent"] = TorrentCard,
            ["blessing"] = BlessingCard,
            ["portal"] = PortalCard,
            ["gem"] = GemCard,
        },
        cardToCharacter = {}, -- Map of card name to character name
        cardNames = {} -- List of card names
    }
    for cardName, _ in pairs(manager.cardTypes) do
        table.insert(manager.cardNames, cardName)
    end

    for cardName, charName in pairs(ctx.characterManager.cardToCharacter) do
        manager.cardToCharacter[cardName] = charName
    end

    return setmetatable(manager, self)
end

function CardManager:createCard(cardName)
    local CardClass = self.cardTypes[cardName]
    if CardClass then
        local card = CardClass:new(self.ctx, 0, 0)
        local charName = self.cardToCharacter[cardName]
        card.character = charName
        card.color = self.ctx.characterManager.characters[charName].color
        return card
    else
        error("Unknown card type: " .. tostring(cardName))
    end
end

function CardManager:getAllCardNames()
    return self.cardNames
end

function CardManager:getRandomCards(count, characterName)
    local cards = {}
    for cardName, cardCharacter in pairs(self.cardToCharacter) do
        if cardCharacter == characterName then
            table.insert(cards, cardName)
        end
    end

    local randomCards = {}
    for i = 1, count do
        local cardIdx = math.random(1, #cards)
        local cardName = cards[cardIdx]
        table.remove(cards, cardIdx)
        table.insert(randomCards, self:createCard(cardName))
    end
    return randomCards
end