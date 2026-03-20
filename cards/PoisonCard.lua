require "cards.BaseCard"
require "spells.PoisonSpell"

PoisonCard = {}
setmetatable(PoisonCard, {
    __index = BaseCard
})
PoisonCard.__index = PoisonCard

function PoisonCard:new(ctx, x, y)
    local card = BaseCard:new(ctx, x, y)
    card.name = "poison"
    card.mana = 3
    card.elem = "fire"
    card.anim = ctx.resourceManager:newAnimation("card_" .. card.name)

    card.SpellClass = PoisonSpell
    card.spellData = { 
        stacksToAdd = 5,
    }
    setmetatable(card, self)
    return card
end

function PoisonCard:getDescription()
    return "apply " .. self.spellData.stacksToAdd .. " stacks of poison."
end
