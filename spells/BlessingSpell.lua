require "spells.BaseSpell"
require "effects.HealthRegenEffect"

BlessingSpell = {}
setmetatable(BlessingSpell, { __index = BaseSpell })
BlessingSpell.__index = BlessingSpell

function BlessingSpell:new(caster, target, spellData, anim)
    local spell = BaseSpell:new(caster, target, spellData, anim)
    spell.x = caster.renderer.x
    spell.y = caster.renderer.y
    spell.anim.offsetX = 8
    spell.anim.offsetY = 20
    spell:playOnce()
    return setmetatable(spell, self)
end

function BlessingSpell:onStart()
    local player = self.caster.player
    player:applyEffect(HealthRegenEffect:new(player, self.spellData.regenAmount))
end
