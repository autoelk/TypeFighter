require "cards.BaseCard"

TyphoonCard = {}
setmetatable(TyphoonCard, {__index = BaseCard})
TyphoonCard.__index = TyphoonCard

function TyphoonCard:new(cardData)
    local card = BaseCard:new(cardData)
    card.name = "typhoon"
    card.damage = 1000
    card.mana = 50
    card.type = "attack"
    card.elem = "water"
    card.loc = "other"
    setmetatable(card, self)
    return card
end

function TyphoonCard:getDescription()
    return "deal " .. self.damage .. " damage."
end

function TyphoonCard:cast(caster, target)
    target:Damage(self.damage)
    return true
end