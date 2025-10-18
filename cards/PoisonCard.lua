require "cards.BaseCard"
require "spells.PoisonSpell"

PoisonCard = {}
setmetatable(PoisonCard, {
    __index = BaseCard
})
PoisonCard.__index = PoisonCard

function PoisonCard:new(x, y)
    local card = BaseCard:new(x, y)
    card.name = "poison"
    card.mana = 5
    card.elem = "fire"
    card.anim = resourceManager:newAnimation("card_" .. card.name)

    card.SpellClass = PoisonSpell
    card.spellData = { damagePerTick = 1, duration = 5, maxStacks = 5 }
    setmetatable(card, self)
    return card
end

function PoisonCard:getDescription()
    return "apply stacking poison for " .. self.spellData.duration .. "s."
end
