-- Abstract base Effect class that all effects inherit from
BaseEffect = {}
BaseEffect.__index = BaseEffect

function BaseEffect:new(name, player, initialStacks)
    local effect = {
        -- Config
        name = name,
        player = player,
        stacks = initialStacks
    }
    return setmetatable(effect, self)
end

function BaseEffect:onApply()
    -- Either implemented by subclass or does nothing
end

-- Effects tick when the player casts a spell
function BaseEffect:onTick(card, incantation)
    -- Either implemented by subclass or does nothing
end

-- When there are no stacks left
function BaseEffect:onExpire()
    -- Either implemented by subclass or does nothing
end

function BaseEffect:addStacks(stacksToAdd)
    self.stacks = self.stacks + stacksToAdd
end