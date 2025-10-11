require "cards.BaseCard"

SliceCard = {}
setmetatable(SliceCard, {
    __index = BaseCard
})
SliceCard.__index = SliceCard

function SliceCard:new(cardData)
    local card = BaseCard:new(cardData)
    card.name = "slice"
    card.mana = 15
    card.ratio = 1 / 2
    card.type = "misc"
    card.elem = "fire"
    card.loc = "other"
    setmetatable(card, self)
    return card
end

function SliceCard:getDescription()
    return "deal damage equal to " .. math.floor(self.ratio * 100) .. "% of enemy health."
end

function SliceCard:cast(caster, target)
    if caster.health > self.healthThreshold then
        target:damage(math.floor(target.health * self.ratio))
        return true
    end
    return false
end
