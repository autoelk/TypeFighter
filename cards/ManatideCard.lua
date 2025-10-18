require "cards.BaseCard"
require "spells.ManatideSpell"

ManatideCard = {}
setmetatable(ManatideCard, {
    __index = BaseCard
})
ManatideCard.__index = ManatideCard

function ManatideCard:new(x, y)
    local card = BaseCard:new(x, y)
    card.name = "manatide"
    card.mana = 5
    card.elem = "water"
    card.anim = resourceManager:newAnimation("card_" .. card.name)

    card.SpellClass = ManatideSpell
    card.spellData = { regenBonus = 1, duration = 10 }
    setmetatable(card, self)
    return card
end

function ManatideCard:getDescription()
    return "+" .. self.spellData.regenBonus .. " mana/sec for " .. self.spellData.duration .. " seconds."
end
