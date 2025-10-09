require "cards.BaseCard"

RitualCard = {}
setmetatable(RitualCard, {
    __index = BaseCard
})
RitualCard.__index = RitualCard

function RitualCard:new(cardData)
    local card = BaseCard:new(cardData)
    card.name = "ritual"
    card.healthCost = 50 -- Health cost
    card.manaGain = 30 -- Mana gained
    card.mana = 0
    card.type = "misc"
    card.elem = "fire"
    card.loc = "self"
    setmetatable(card, self)
    return card
end

function RitualCard:getDescription()
    return "lose " .. self.healthCost .. " health, gain " .. self.manaGain .. " mana."
end

function RitualCard:cast(caster, target)
    caster:damage(self.healthCost) -- Take damage
    caster.mana = caster.mana + self.manaGain -- Gain mana
    return true
end
