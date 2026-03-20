require "spells.BaseSpell"
require "effects.HealthRegenEffect"

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
    local player = self.caster.player
    player:applyEffect(HealthRegenEffect:new(self.spellData.effectName, player, self.spellData.duration, self.spellData.regenAmount))
end
