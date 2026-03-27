require "cards.BaseCard"
require "spells.FireballSpell"

FireballCard = {}
setmetatable(FireballCard, {
    __index = BaseCard
})
FireballCard.__index = FireballCard

function FireballCard:new(ctx, x, y)
    local card = BaseCard:new(ctx, x, y)
    card.name = "fireball"
    card.incantationLength = 3
    card.elem = "fire"
    card.anim = ctx.resourceManager:newAnimation("card_" .. card.name)

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
