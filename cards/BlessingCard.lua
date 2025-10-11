require "cards.BaseCard"

BlessingCard = {}
setmetatable(BlessingCard, {
    __index = BaseCard
})
BlessingCard.__index = BlessingCard

function BlessingCard:new(cardData)
    local card = BaseCard:new(cardData)
    card.name = "blessing"
    card.regenAmount = 1 -- Health regen amount
    card.duration = 15   -- Duration of the effect in seconds
    card.mana = 8
    card.type = "misc"
    card.elem = "earth"
    card.loc = "self"
    card.offsetY = 20
    card.offsetX = 10
    setmetatable(card, self)
    return card
end

function BlessingCard:getDescription()
    return "+" .. self.regenAmount .. " health/sec for " .. self.duration .. " seconds."
end

function BlessingCard:cast(caster, target)
    caster:applyEffect("blessing", {
        duration = 10,
        onApply = function(p, eff)
            p.healthRegen = p.healthRegen + self.regenAmount
        end,
        onExpire = function(p, eff)
            p.healthRegen = p.healthRegen - self.regenAmount
        end
    })
    return true
end
