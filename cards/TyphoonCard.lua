require "cards.BaseCard"
require "spells.TyphoonSpell"

TyphoonCard = {}
setmetatable(TyphoonCard, {
    __index = BaseCard
})
TyphoonCard.__index = TyphoonCard

function TyphoonCard:new(ctx, x, y)
    local card = BaseCard:new(ctx, x, y)
    card.name = "typhoon"
    card.incantationLength = 15
    card:setCharacter("wizard")
    card.anim = ctx.resourceManager:newAnimation("card_" .. card.name)

    card.SpellClass = TyphoonSpell
    card.spellData = { damage = 100 }
    setmetatable(card, self)
    return card
end

function TyphoonCard:getDescription()
    return "deal " .. self.spellData.damage .. " damage."
end
