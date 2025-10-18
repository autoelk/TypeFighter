require "cards.BaseCard"
require "spells.RitualSpell"

RitualCard = {}
setmetatable(RitualCard, {
    __index = BaseCard
})
RitualCard.__index = RitualCard

function RitualCard:new(x, y)
    local card = BaseCard:new(x, y)
    card.name = "ritual"
    card.mana = 5
    card.elem = "fire"
    card.anim = resourceManager:newAnimation("card_" .. card.name)

    card.SpellClass = RitualSpell
    card.spellData = { healthCost = 30, manaGain = 20 }
    setmetatable(card, self)
    return card
end

function RitualCard:getDescription()
    return "lose " .. self.spellData.healthCost .. " health, gain " .. self.spellData.manaGain .. " mana."
end
