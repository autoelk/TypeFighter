require "cards.BaseCard"

SliceCard = {}
setmetatable(SliceCard, {
    __index = BaseCard
})
SliceCard.__index = SliceCard

function SliceCard:new(cardData)
    local card = BaseCard:new(cardData)
    card.name = "slice"
    card.damage = 100
    card.healthThreshold = 100 -- Health threshold required to cast
    card.mana = 0
    card.type = "misc"
    card.elem = "fire"
    card.loc = "other"
    setmetatable(card, self)
    return card
end

function SliceCard:getDescription()
    return "deal " .. self.damage .. " damage if you have over " .. self.healthThreshold .. " health."
end

function SliceCard:canCast(caster, target)
    local canCast, errorMessage = BaseCard.canCast(self, caster, target)
    if not canCast then
        return false, errorMessage
    end

    -- Check health requirement
    if caster.health <= self.healthThreshold then
        return false, "you need more than " .. self.healthThreshold .. " health to cast this"
    end

    return true, nil
end

function SliceCard:cast(caster, target)
    if caster.health > self.healthThreshold then
        target:damage(self.damage)
        return true
    end
    return false
end
