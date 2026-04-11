require "cards.BaseCard"
require "spells.LacerateSpell"

LacerateCard = {}
setmetatable(LacerateCard, {
    __index = BaseCard
})
LacerateCard.__index = LacerateCard

function LacerateCard:new(ctx, x, y)
    local card = BaseCard:new(ctx, x, y)
    card.name = "lacerate"
    card.incantationLength = 2
    card:setCharacter("vampire")
    card.anim = ctx.resourceManager:newAnimation("card_" .. card.name)

    card.SpellClass = LacerateSpell
    card.spellData = { 
        stacksToAdd = 5,
    }
    setmetatable(card, self)
    return card
end

function LacerateCard:getDescription()
    return "apply " .. self.spellData.stacksToAdd .. " stacks of bleed."
end
