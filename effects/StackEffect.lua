require "effects.BaseEffect"

-- Stack Effects are effects that only apply to the player once
-- They have stacks and end when the stacks are depleted
StackEffect = {}
setmetatable(StackEffect, { __index = BaseEffect })
StackEffect.__index = StackEffect

function StackEffect:new(name, player, initialStacks)
    local effect = BaseEffect:new(player)
    effect.name = name
    effect.type = "stack"
    effect.stacks = initialStacks
    return setmetatable(effect, self)
end

function StackEffect:update(dt)
    BaseEffect.update(self, dt)

    if self.stacks <= 0 then
        self.expired = true
    end
end

function StackEffect:addStacks(stacksToAdd)
    self.stacks = self.stacks + stacksToAdd
end