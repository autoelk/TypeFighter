require "cards.BaseCard"

PunchCard = {}
setmetatable(PunchCard, {
    __index = BaseCard
})
PunchCard.__index = PunchCard

function PunchCard:new(cardData)
    local card = BaseCard:new(cardData)
    card.name = "punch"
    card.damage = 2
    card.mana = 0
    card.type = "attack"
    card.elem = "earth"
    card.loc = "other"
    card.offsetX = -90
    card.offsetY = 15
    setmetatable(card, self)
    return card
end

function PunchCard:getDescription()
    return "deal " .. self.damage .. " damage."
end

function PunchCard:cast(caster, target)
    target:Damage(self.damage)
    return true
end
