require "effects.BaseEffect"

HealthRegenEffect = {}
setmetatable(HealthRegenEffect, { __index = BaseEffect })
HealthRegenEffect.__index = HealthRegenEffect

function HealthRegenEffect:new(player, initialStacks)
    local effect = BaseEffect:new("health regen", player, initialStacks)
    return setmetatable(effect, self)
end

function HealthRegenEffect:onTick()
    self.player:heal(self.stacks)
    self.stacks = self.stacks - 1
end