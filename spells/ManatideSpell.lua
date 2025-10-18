require "spells.BaseSpell"

ManatideSpell = {}
setmetatable(ManatideSpell, { __index = BaseSpell })
ManatideSpell.__index = ManatideSpell

function ManatideSpell:new(caster, target, spellData, anim)
    local spell = BaseSpell:new(caster, target, spellData, anim)
    spell.x = caster.x
    spell.y = caster.y
    spell:playLoopFor(spellData.duration)
    return setmetatable(spell, self)
end

function ManatideSpell:onStart()
    self.caster:applyEffect("manatide", {
        duration = self.spellData.duration,
        onApply = function(p, eff)
            p.manaRegen = p.manaRegen + self.spellData.regenBonus
        end,
        onExpire = function(p, eff)
            p.manaRegen = p.manaRegen - self.spellData.regenBonus
        end
    })
end
