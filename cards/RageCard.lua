require "cards.BaseCard"

RageCard = {}
setmetatable(RageCard, {__index = BaseCard})
RageCard.__index = RageCard

function RageCard:new(cardData)
    local card = BaseCard:new(cardData)
    card.name = "rage"
    card.baseDamage = 50 -- Base damage calculation (50 - health)
    card.mana = 20
    card.type = "misc"
    card.elem = "fire"
    card.loc = "proj"
    setmetatable(card, self)
    return card
end

function RageCard:getDescription()
    return "deal damage equal to (" .. self.baseDamage .. " - your health)."
end

function RageCard:cast(caster, target)
    local damage = self.baseDamage - caster.health
    target:Damage(damage)
    return true
end