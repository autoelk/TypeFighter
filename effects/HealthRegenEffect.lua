require "effects.DurationEffect"

HealthRegenEffect = {}
setmetatable(HealthRegenEffect, { __index = DurationEffect })
HealthRegenEffect.__index = HealthRegenEffect

function HealthRegenEffect:new(name, player, duration, regenAmount)
    local effect = DurationEffect:new(player, duration)
    effect.name = name
    effect.regenAmount = regenAmount
    return setmetatable(effect, self)
end

function HealthRegenEffect:onTick()
    self.player:damage(-self.regenAmount)
end