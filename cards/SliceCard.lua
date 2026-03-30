require "cards.BaseCard"
require "spells.SliceSpell"

SliceCard = {}
setmetatable(SliceCard, {
    __index = BaseCard
})
SliceCard.__index = SliceCard

function SliceCard:new(ctx, x, y)
    local card = BaseCard:new(ctx, x, y)
    card.name = "slice"
    card.incantationLength = 3
    card:setCharacter("vampire")
    card.anim = ctx.resourceManager:newAnimation("card_" .. card.name)

    card.SpellClass = SliceSpell
    card.spellData = { ratio = 1 / 2 }
    setmetatable(card, self)
    return card
end

function SliceCard:getDescription()
    return "deal damage equal to " .. math.floor(self.spellData.ratio * 100) .. "% of enemy health."
end
