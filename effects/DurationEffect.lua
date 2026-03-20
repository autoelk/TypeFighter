require "effects.BaseEffect"

-- Duration Effects are effects that apply to the player independently of other instances of the same effect
-- They have a duration and are removed when the duration is up
DurationEffect = {}
setmetatable(DurationEffect, { __index = BaseEffect })
DurationEffect.__index = DurationEffect

function DurationEffect:new(player, duration)
    local effect = BaseEffect:new(player)
    effect.type = "duration"
    effect.timeLeft = duration -- Set to nil for infinite duration
    return setmetatable(effect, self)
end

function DurationEffect:update(dt)
    BaseEffect.update(self, dt)

    if self.timeLeft == nil then
        return
    end

    self.timeLeft = self.timeLeft - dt
    if self.timeLeft <= 0 then
        self.expired = true
    end
end