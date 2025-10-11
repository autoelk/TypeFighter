require "cards.BaseCard"

HealCard = {}
setmetatable(HealCard, {
    __index = BaseCard
})
HealCard.__index = HealCard

function HealCard:new(cardData)
    local card = BaseCard:new(cardData)
    card.name = "heal"
    card.healAmount = 10
    card.mana = 5
    card.type = "heal"
    card.elem = "earth"
    card.loc = "self"
    setmetatable(card, self)
    return card
end

function HealCard:getDescription()
    return "gain " .. self.healAmount .. " health."
end

function HealCard:cast(caster, target)
    -- Heal the caster (negative damage)
    caster:damage(-self.healAmount)
    return true
end
