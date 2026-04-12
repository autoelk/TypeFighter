require "Card"

local Cards = require "definitions.Cards"

CardManager = {}
CardManager.__index = CardManager

function CardManager:new(ctx)
    if not ctx then
        error("CardManager:new(ctx) requires ctx")
    end
    local manager = {
        ctx = ctx,
        cardToCharacter = {}, -- Map of card name to character name
        cardNames = {}, -- List of all card names
    }

    for name in pairs(Cards) do
        table.insert(manager.cardNames, name)
    end
    table.sort(manager.cardNames)

    for cardName, charName in pairs(ctx.characterManager.cardToCharacter) do
        manager.cardToCharacter[cardName] = charName
    end

    return setmetatable(manager, self)
end

function CardManager:createCard(cardName)
    if Cards[cardName] then
        local card = Card:new(self.ctx, cardName, 0, 0)
        local charName = card.character
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
    local pool = {}
    for cardName, cardCharacter in pairs(self.cardToCharacter) do
        if cardCharacter == characterName then
            table.insert(pool, cardName)
        end
    end

    local randomCards = {}
    for i = 1, count do
        local cardIdx = math.random(1, #pool)
        local cardName = pool[cardIdx]
        table.remove(pool, cardIdx)
        table.insert(randomCards, self:createCard(cardName))
    end
    return randomCards
end
