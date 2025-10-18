require "cards.BaseCard"
require "spells.PunchSpell"

PunchCard = {}
setmetatable(PunchCard, {
    __index = BaseCard
})
PunchCard.__index = PunchCard

function PunchCard:new(x, y)
    local card = BaseCard:new(x, y)
    card.name = "punch"
    card.mana = 0
    card.elem = "earth"
    card.anim = resourceManager:newAnimation("card_" .. card.name)

    card.SpellClass = PunchSpell
    card.spellData = { damage = 2 }
    setmetatable(card, self)
    return card
end

function PunchCard:getDescription()
    return "deal " .. self.spellData.damage .. " damage."
end
