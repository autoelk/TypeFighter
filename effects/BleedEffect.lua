require "effects.StackEffect"

BleedEffect = {}
setmetatable(BleedEffect, { __index = StackEffect })
BleedEffect.__index = BleedEffect

function BleedEffect:new(player, initialStacks)
    local effect = StackEffect:new("bleed", player, initialStacks)
    effect.tickInterval = 5
    return setmetatable(effect, self)
end
    
function BleedEffect:onTick()
    self.player:damage(self.stacks)
    self.stacks = self.stacks - 1
end