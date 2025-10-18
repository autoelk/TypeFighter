require "spells.BaseSpell"

PoisonSpell = {}
setmetatable(PoisonSpell, { __index = BaseSpell })
PoisonSpell.__index = PoisonSpell

function PoisonSpell:new(caster, target, spellData, anim)
    local spell = BaseSpell:new(caster, target, spellData, anim)
    spell.x = target.x
    spell.y = target.y
    spell:playOnce()
    return setmetatable(spell, self)
end

function PoisonSpell:onStart()
    self.target:applyEffect("poison", {
        duration = self.spellData.duration,
        tickInterval = 1,
        stackMode = "stack",
        maxStacks = self.spellData.maxStacks or 5,
        onTick = function(player, eff)
            player:damage(eff.stacks * self.spellData.damagePerTick)
        end
    })
end
