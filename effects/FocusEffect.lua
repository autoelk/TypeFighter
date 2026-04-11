require "effects.BaseEffect"

FocusEffect = {}
setmetatable(FocusEffect, { __index = BaseEffect })
FocusEffect.__index = FocusEffect

function FocusEffect:new(player, initialStacks)
    local effect = BaseEffect:new("focus", player, initialStacks)
    return setmetatable(effect, self)
end

function FocusEffect:onApply()
    self.player.focus = self.player.focus + self.stacks
end

function FocusEffect:onTick()
    if self.stacks > 0 then
        self.stacks = self.stacks - 1
        self.player.focus = self.player.focus - 1
    elseif self.stacks < 0 then
        self.stacks = self.stacks + 1
        self.player.focus = self.player.focus + 1
    end
end