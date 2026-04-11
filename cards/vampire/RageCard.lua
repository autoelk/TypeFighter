require "cards.BaseCard"
require "spells.vampire.RageSpell"

RageCard = {}
setmetatable(RageCard, {
    __index = BaseCard
})
RageCard.__index = RageCard

function RageCard:new(ctx, x, y)
    local card = BaseCard:new(ctx, x, y)
    card.name = "rage"
    card.incantationLength = 5
    card:setCharacter("vampire")
    card.anim = ctx.resourceManager:newAnimation("card_" .. card.name)

    card.SpellClass = RageSpell
    card.spellData = { damage = 30, healthCost = 10 }
    setmetatable(card, self)
    return card
end

function RageCard:getDescription()
    return "lose " .. self.spellData.healthCost .. " health, deal " .. self.spellData.damage .. " damage."
end
