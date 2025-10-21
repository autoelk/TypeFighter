require "spells.BaseSpell"

BlessingSpell = {}
setmetatable(BlessingSpell, { __index = BaseSpell })
BlessingSpell.__index = BlessingSpell

function BlessingSpell:new(caster, target, spellData, anim)
    local spell = BaseSpell:new(caster, target, spellData, anim)
    spell.x = caster.x
    spell.y = caster.y
    spell.anim.offsetX = 10
    spell.anim.offsetY = 20
    spell:playLoopFor(spellData.duration)
    setmetatable(spell, self)
    return spell
end

function BlessingSpell:onStart()
    self.caster.player:applyEffect("blessing", {
        duration = self.spellData.duration,
        onApply = function(p, eff)
            p.healthRegen = p.healthRegen + self.spellData.regenAmount
        end,
        onExpire = function(p, eff)
            p.healthRegen = p.healthRegen - self.spellData.regenAmount
        end
    })
end
