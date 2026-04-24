require "effects.BaseEffect"

ShiftedEffect = {}
setmetatable(ShiftedEffect, { __index = BaseEffect })
ShiftedEffect.__index = ShiftedEffect

function ShiftedEffect:new(player, initialStacks)
    local effect = BaseEffect:new("shifted", player, initialStacks)
    return setmetatable(effect, self)
end

function ShiftedEffect:onApply()
    self.player.shifted = self.player.shifted + self.stacks
end

function ShiftedEffect:onTick(card, incantation)
    self.stacks = self.stacks - 1
    self.player.shifted = self.player.shifted - 1
end