require "cards.BaseCard"
require "spells.vampire.CoagulateSpell"

CoagulateCard = {}
setmetatable(CoagulateCard, {__index = BaseCard})
CoagulateCard.__index = CoagulateCard

function CoagulateCard:new(ctx, x, y)
    local card = BaseCard:new(ctx, x, y)
    card.name = "coagulate"
    card.incantationLength = 5
    card:setCharacter("vampire")
    card.anim = ctx.resourceManager:newAnimation("card_" .. card.name)

    card.SpellClass = CoagulateSpell
    card.spellData = {
        healthCost = 5,
        shieldAmount = 20
    }
    return setmetatable(card, self)
end

function CoagulateCard:getDescription()
    return "lose " .. self.spellData.healthCost .. " health, gain " .. self.spellData.shieldAmount .. " shield."
end