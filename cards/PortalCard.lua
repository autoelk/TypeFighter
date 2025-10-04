require "cards.BaseCard"

PortalCard = {}
setmetatable(PortalCard, {
    __index = BaseCard
})
PortalCard.__index = PortalCard

function PortalCard:new(cardData)
    local card = BaseCard:new(cardData)
    card.name = "portal"
    card.damage = 40
    card.mana = 20
    card.type = "attack"
    card.elem = "water"
    card.loc = "other"
    setmetatable(card, self)
    return card
end

function PortalCard:getDescription()
    return "deal " .. self.damage .. " damage."
end

function PortalCard:cast(caster, target)
    target:Damage(self.damage)
    return true
end
