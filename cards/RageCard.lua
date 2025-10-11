require "cards.BaseCard"

RageCard = {}
setmetatable(RageCard, {
    __index = BaseCard
})
RageCard.__index = RageCard

function RageCard:new(cardData)
    local card = BaseCard:new(cardData)
    card.name = "rage"
    card.damage = 30
    card.healthCost = 10
    card.mana = 10
    card.type = "misc"
    card.elem = "fire"
    card.loc = "proj"
    card.offsetY = 15
    setmetatable(card, self)
    return card
end

function RageCard:getDescription()
    return "lose " .. self.healthCost .. " health, deal " .. self.damage .. " damage."
end

function RageCard:cast(caster, target)
    caster:damage(self.healthCost)
    target:damage(self.damage)
    return true
end
