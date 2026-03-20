require "effects.StackEffect"

PoisonEffect = {}
setmetatable(PoisonEffect, { __index = StackEffect })
PoisonEffect.__index = PoisonEffect

function PoisonEffect:new(player, initialStacks)
    local effect = StackEffect:new("poison", player, initialStacks)
    effect.tickInterval = 5
    return setmetatable(effect, self)
end
    
function PoisonEffect:onTick()
    self.player:damage(self.stacks)
    self.stacks = self.stacks - 1
end