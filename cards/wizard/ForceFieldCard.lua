require "cards.BaseCard"
require "spells.wizard.ForceFieldSpell"

ForceFieldCard = {}
setmetatable(ForceFieldCard, {__index = BaseCard})
ForceFieldCard.__index = ForceFieldCard

function ForceFieldCard:new(ctx, x, y)
    local card = BaseCard:new(ctx, x, y)
    card.name = "forcefield"
    card.incantationLength = 1
    card.anim = ctx.resourceManager:newAnimation("card_" .. card.name, "loop")

    card.SpellClass = ForceFieldSpell
    card.spellData = {
        shieldAmount = 5
    }
    return setmetatable(card, self)
end

function ForceFieldCard:getDescription()
    return "gain " .. self.spellData.shieldAmount .. " shield."
end
