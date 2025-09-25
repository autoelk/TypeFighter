require "cards.BaseCard"

BoltCard = {}
setmetatable(BoltCard, {__index = BaseCard})
BoltCard.__index = BoltCard

function BoltCard:new(cardData)
    local card = BaseCard:new(cardData)
    card.name = "bolt"
    card.damage = 4
    card.mana = 1
    card.type = "attack"
    card.elem = "fire"
    card.loc = "other"
    setmetatable(card, self)
    return card
end

function BoltCard:getDescription()
    return "deal " .. self.damage .. " damage."
end

function BoltCard:cast(caster, target)
    target:Damage(self.damage)
    return true
end