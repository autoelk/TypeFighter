require "cards.BaseCard"
require "spells.RageSpell"

RageCard = {}
setmetatable(RageCard, {
    __index = BaseCard
})
RageCard.__index = RageCard

function RageCard:new(x, y)
    local card = BaseCard:new(x, y)
    card.name = "rage"
    card.mana = 10
    card.elem = "fire"
    card.anim = resourceManager:newAnimation("card_" .. card.name)

    card.SpellClass = RageSpell
    card.spellData = { damage = 30, healthCost = 10 }
    setmetatable(card, self)
    return card
end

function RageCard:getDescription()
    return "lose " .. self.spellData.healthCost .. " health, deal " .. self.spellData.damage .. " damage."
end
