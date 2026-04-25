require "spells.BaseSpell"
require "effects.BloodPactEffect"

BloodPactSpell = {}
setmetatable(BloodPactSpell, {__index = BaseSpell})
BloodPactSpell.__index = BloodPactSpell

function BloodPactSpell:new(caster, target, spellData, anim)
    local spell = BaseSpell:new(caster, target, spellData, anim)
    spell.x = caster.renderer.x
    spell.y = caster.renderer.y
    spell.anim.offsetX = 64
    spell:playOnce()
    return setmetatable(spell, self)
end

function BloodPactSpell:onStart()
    local player = self.caster.player
    player:applyEffect(BloodPactEffect:new(player, 1))
end