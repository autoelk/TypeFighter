require "cards.BaseCard"

ManatideCard = {}
setmetatable(ManatideCard, {__index = BaseCard})
ManatideCard.__index = ManatideCard

function ManatideCard:new(cardData)
    local card = BaseCard:new(cardData)
    card.name = "manatide"
    card.damage = 0
    card.mana = 10
    card.type = "misc"
    card.elem = "water"
    card.loc = "self"
    setmetatable(card, self)
    return card
end

function ManatideCard:getDescription()
    return "double your current mana."
end

function ManatideCard:cast(caster, target)
    caster.mana = caster.mana * 2
    return true
end