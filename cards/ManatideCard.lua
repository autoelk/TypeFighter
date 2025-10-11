require "cards.BaseCard"

ManatideCard = {}
setmetatable(ManatideCard, {
    __index = BaseCard
})
ManatideCard.__index = ManatideCard

function ManatideCard:new(cardData)
    local card = BaseCard:new(cardData)
    card.name = "manatide"
    card.damage = 0
    card.mana = 5
    card.type = "misc"
    card.elem = "water"
    card.loc = "self"
    card.regenBonus = 1 -- additional mana regen per second
    card.duration = 10
    setmetatable(card, self)
    return card
end

function ManatideCard:getDescription()
    return "+" .. self.regenBonus .. " mana/sec for " .. self.duration .. " seconds."
end

function ManatideCard:cast(caster, target)
    caster:applyEffect("manatide", {
        duration = self.duration,
        onApply = function(p, eff)
            p.manaRegen = p.manaRegen + self.regenBonus
        end,
        onExpire = function(p, eff)
            p.manaRegen = p.manaRegen - self.regenBonus
        end
    })
    return true
end
