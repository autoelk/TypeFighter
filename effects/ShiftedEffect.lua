require "effects.BaseEffect"

ShiftedEffect = {}
setmetatable(ShiftedEffect, { __index = BaseEffect })
ShiftedEffect.__index = ShiftedEffect

function ShiftedEffect:new(player, initialStacks)
    local effect = BaseEffect:new("shifted", player, initialStacks)
    return setmetatable(effect, self)
end

function ShiftedEffect:onApply()
    self.player.shifted = true
end

function ShiftedEffect:onTick(card, incantation)
    if self.stacks > 0 then
        self.stacks = self.stacks - 1
    end
end

function ShiftedEffect:onExpire()
    self.player.shifted = false
end