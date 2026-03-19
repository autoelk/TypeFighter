require "cards.BaseCard"
require "spells.GemSpell"

GemCard = {}
setmetatable(GemCard, {
    __index = BaseCard
})
GemCard.__index = GemCard

function GemCard:new(ctx, x, y)
    local card = BaseCard:new(ctx, x, y)
    card.name = "gem"
    card.mana = 10
    card.elem = "water"
    card.anim = ctx.resourceManager:newAnimation("card_" .. card.name)

    card.SpellClass = GemSpell
    card.spellData = { regenAmount = 0.5 }
    setmetatable(card, self)
    return card
end

function GemCard:getDescription()
    return "+" .. self.spellData.regenAmount .. " mana/sec."
end
