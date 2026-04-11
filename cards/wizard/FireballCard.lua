require "cards.BaseCard"
require "spells.wizard.FireballSpell"

FireballCard = {}
setmetatable(FireballCard, {
    __index = BaseCard
})
FireballCard.__index = FireballCard

function FireballCard:new(ctx, x, y)
    local card = BaseCard:new(ctx, x, y)
    card.name = "fireball"
    card.incantationLength = 2
    card:setCharacter("wizard")
    card.anim = ctx.resourceManager:newAnimation("card_" .. card.name)

    card.SpellClass = FireballSpell
    card.spellData = {
        damage = 15,
        focusAmount = -3
    }
    setmetatable(card, self)
    return card
end

function FireballCard:getDescription()
    return "lose " .. math.abs(self.spellData.focusAmount) .. " focus. deal " .. self.spellData.damage .. " damage."
end
