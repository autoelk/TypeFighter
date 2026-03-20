require "cards.BaseCard"
require "spells.ManatideSpell"

ManatideCard = {}
setmetatable(ManatideCard, {
    __index = BaseCard
})
ManatideCard.__index = ManatideCard

function ManatideCard:new(ctx, x, y)
    local card = BaseCard:new(ctx, x, y)
    card.name = "manatide"
    card.mana = 5
    card.elem = "water"
    card.anim = ctx.resourceManager:newAnimation("card_" .. card.name)

    card.SpellClass = ManatideSpell
    card.spellData = { 
        effectName = card.name,
        regenAmount = 1, 
        duration = 10 
    }
    setmetatable(card, self)
    return card
end

function ManatideCard:getDescription()
    return "+" .. self.spellData.regenAmount .. " mana/sec for " .. self.spellData.duration .. " seconds."
end
