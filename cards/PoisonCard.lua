require "cards.BaseCard"

PoisonCard = {}
setmetatable(PoisonCard, {
    __index = BaseCard
})
PoisonCard.__index = PoisonCard

function PoisonCard:new(cardData)
    local card = BaseCard:new(cardData)
    card.name = "poison"
    card.damagePerTick = 1
    card.duration = 5
    card.mana = 5
    card.type = "misc"
    card.elem = "fire"
    card.loc = "other"
    card.offsetY = 15
    setmetatable(card, self)
    return card
end

function PoisonCard:getDescription()
    return "apply stacking poison for " .. self.duration .. "s."
end

function PoisonCard:cast(caster, target)
    target:applyEffect("poison", {
        duration = self.duration,
        tickInterval = 1,
        stackMode = "stack",
        maxStacks = 5,
        onTick = function(player, eff)
            player:damage(eff.stacks * self.damagePerTick)
        end
    })
    return true
end
