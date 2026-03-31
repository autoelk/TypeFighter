require "cards.BaseCard"
require "spells.ForceFieldSpell"

ForceFieldCard = {}
setmetatable(ForceFieldCard, {
    __index = BaseCard
})
ForceFieldCard.__index = ForceFieldCard

function ForceFieldCard:new(ctx, x, y)
    local card = BaseCard:new(ctx, x, y)
    card.name = "forcefield"
    card.incantationLength = 2
    card:setCharacter("wizard")
    card.anim = ctx.resourceManager:newAnimation("card_" .. card.name)

    card.SpellClass = ForceFieldSpell
    card.spellData = {
        shieldAmount = 10
    }
    setmetatable(card, self)
    return card
end

function ForceFieldCard:getDescription()
    return "gain " .. self.spellData.shieldAmount .. " shield."
end
