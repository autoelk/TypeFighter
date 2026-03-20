require "effects.DurationEffect"

ManaRegenEffect = {}
setmetatable(ManaRegenEffect, { __index = DurationEffect })
ManaRegenEffect.__index = ManaRegenEffect

function ManaRegenEffect:new(name, player, duration, regenAmount)
    local effect = DurationEffect:new(player, duration)
    effect.name = name
    effect.regenAmount = regenAmount
    return setmetatable(effect, self)
end
    
function ManaRegenEffect:onTick()
    self.player.mana = self.player.mana + self.regenAmount
end