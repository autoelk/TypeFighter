require "cards.BaseCard"

GemCard = {}
setmetatable(GemCard, {
    __index = BaseCard
})
GemCard.__index = GemCard

function GemCard:new(cardData)
    local card = BaseCard:new(cardData)
    card.name = "gem"
    card.regenAmount = 0.5 -- Amount of mana regen to add
    card.mana = 10
    card.type = "misc"
    card.elem = "water"
    card.loc = "self"
    card.offsetY = -100
    setmetatable(card, self)
    return card
end

function GemCard:getDescription()
    return "+" .. self.regenAmount .. " mana/sec."
end

function GemCard:cast(caster, target)
    caster.manaRegen = caster.manaRegen + self.regenAmount
    return true
end
