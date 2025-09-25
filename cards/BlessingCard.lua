require "cards.BaseCard"

BlessingCard = {}
setmetatable(BlessingCard, {__index = BaseCard})
BlessingCard.__index = BlessingCard

function BlessingCard:new(cardData)
    local card = BaseCard:new(cardData)
    card.name = "blessing"
    card.regenAmount = 0.75 -- Health regen amount
    card.mana = 10
    card.type = "misc"
    card.elem = "earth"
    card.loc = "self"
    setmetatable(card, self)
    return card
end

function BlessingCard:getDescription()
    return "gain " .. self.regenAmount .. " health regen permanently."
end

function BlessingCard:cast(caster, target)
    caster.healthRegen = caster.healthRegen + self.regenAmount
    return true
end