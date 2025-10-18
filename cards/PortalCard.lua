require "cards.BaseCard"
require "spells.PortalSpell"

PortalCard = {}
setmetatable(PortalCard, {
    __index = BaseCard
})
PortalCard.__index = PortalCard

function PortalCard:new(x, y)
    local card = BaseCard:new(x, y)
    card.name = "portal"
    card.mana = 20
    card.elem = "water"
    card.anim = resourceManager:newAnimation("card_" .. card.name)

    card.SpellClass = PortalSpell
    card.spellData = { damage = 40 }
    setmetatable(card, self)
    return card
end

function PortalCard:getDescription()
    return "deal " .. self.spellData.damage .. " damage."
end
