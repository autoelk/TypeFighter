require "cards.BaseCard"
require "spells.FireballSpell"

FireballCard = {}
setmetatable(FireballCard, {
    __index = BaseCard
})
FireballCard.__index = FireballCard

function FireballCard:new(x, y)
    local card = BaseCard:new(x, y)
    card.name = "fireball"
    card.mana = 3
    card.elem = "fire"
    card.anim = resourceManager:newAnimation("card_" .. card.name)

    card.SpellClass = FireballSpell
    card.spellData = {
        damage = 9
    }
    setmetatable(card, self)
    return card
end

function FireballCard:getDescription()
    return "deal " .. self.spellData.damage .. " damage."
end
