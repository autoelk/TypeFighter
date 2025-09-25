require "cards.BaseCard"

PoisonCard = {}
setmetatable(PoisonCard, {__index = BaseCard})
PoisonCard.__index = PoisonCard

function PoisonCard:new(cardData)
    local card = BaseCard:new(cardData)
    card.name = "poison"
    card.regenAmount = 1
    card.mana = 15
    card.type = "misc"
    card.elem = "fire"
    card.loc = "other"
    setmetatable(card, self)
    return card
end

function PoisonCard:getDescription()
    return "reduce opponent's health regen by " .. self.regenAmount .. "."
end

function PoisonCard:cast(caster, target)
    target.healthRegen = target.healthRegen - self.regenAmount
    return true
end