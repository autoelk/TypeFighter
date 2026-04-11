require "cards.BaseCard"
require "spells.SiphonSpell"

SiphonCard = {}
setmetatable(SiphonCard, {
    __index = BaseCard
})
SiphonCard.__index = SiphonCard

function SiphonCard:new(ctx, x, y)
    local card = BaseCard:new(ctx, x, y)
    card.name = "siphon"
    card.incantationLength = 2
    card:setCharacter("vampire")
    card.anim = ctx.resourceManager:newAnimation("card_" .. card.name)

    card.SpellClass = SiphonSpell
    card.spellData = {}
    setmetatable(card, self)
    return card
end

function SiphonCard:getDescription()
    return "gain shield equal to bleed on the target."
end