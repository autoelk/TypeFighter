require "cards.BaseCard"
require "spells.TyphoonSpell"

TyphoonCard = {}
setmetatable(TyphoonCard, {
    __index = BaseCard
})
TyphoonCard.__index = TyphoonCard

function TyphoonCard:new(x, y)
    local card = BaseCard:new(x, y)
    card.name = "typhoon"
    card.mana = 50
    card.elem = "water"
    card.anim = resourceManager:newAnimation("card_" .. card.name)

    card.SpellClass = TyphoonSpell
    card.spellData = { damage = 100 }
    setmetatable(card, self)
    return card
end

function TyphoonCard:getDescription()
    return "deal " .. self.spellData.damage .. " damage."
end
