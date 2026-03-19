require "cards.BaseCard"
require "spells.HealSpell"

HealCard = {}
setmetatable(HealCard, {
    __index = BaseCard
})
HealCard.__index = HealCard

function HealCard:new(ctx, x, y)
    local card = BaseCard:new(ctx, x, y)
    card.name = "heal"
    card.mana = 5
    card.elem = "earth"
    card.anim = ctx.resourceManager:newAnimation("card_heal")

    card.SpellClass = HealSpell
    card.spellData = { healAmount = 10 }
    setmetatable(card, self)
    return card
end

function HealCard:getDescription()
    return "gain " .. self.spellData.healAmount .. " health."
end
