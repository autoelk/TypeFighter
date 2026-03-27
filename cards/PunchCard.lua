require "cards.BaseCard"
require "spells.PunchSpell"

PunchCard = {}
setmetatable(PunchCard, {
    __index = BaseCard
})
PunchCard.__index = PunchCard

function PunchCard:new(ctx, x, y)
    local card = BaseCard:new(ctx, x, y)
    card.name = "punch"
    card.incantationLength = 1
    card:setCharacter("vampire")
    card.anim = ctx.resourceManager:newAnimation("card_" .. card.name)

    card.SpellClass = PunchSpell
    card.spellData = { damage = 2 }
    setmetatable(card, self)
    return card
end

function PunchCard:getDescription()
    return "deal " .. self.spellData.damage .. " damage."
end
