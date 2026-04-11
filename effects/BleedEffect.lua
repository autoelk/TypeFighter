require "effects.BaseEffect"

BleedEffect = {}
setmetatable(BleedEffect, { __index = BaseEffect })
BleedEffect.__index = BleedEffect

function BleedEffect:new(player, initialStacks)
    local effect = BaseEffect:new("bleed", player, initialStacks)
    return setmetatable(effect, self)
end
    
function BleedEffect:onTick(card, incantation)
    self.player:damage(self.stacks)
    self.stacks = self.stacks - 1
end