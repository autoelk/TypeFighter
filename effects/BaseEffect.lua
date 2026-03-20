-- Abstract base Effect class that all effects inherit from
BaseEffect = {}
BaseEffect.__index = BaseEffect

function BaseEffect:new(player)
    local effect = {
        -- Config
        player = player,
        type = nil,
        name = nil,
        
        -- State
        expired = false,
        tickInterval = 1,
        tickTimer = 0,
    }
    return setmetatable(effect, self)
end

function BaseEffect:update(dt)
    -- Tick the effect if it has a tick interval
    if self.tickInterval then
        self.tickTimer = self.tickTimer + dt
        while self.tickTimer >= self.tickInterval do
            self.tickTimer = self.tickTimer - self.tickInterval
            self:onTick()
        end
    end
end

function BaseEffect:onApply()
    -- Either implemented by subclass or does nothing
end

function BaseEffect:onTick()
    -- Either implemented by subclass or does nothing
end

function BaseEffect:onExpire()
    -- Either implemented by subclass or does nothing
end