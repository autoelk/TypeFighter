require "spells.BaseSpell"
require "effects.BloodPactEffect"

BloodPactSpell = {}
setmetatable(BloodPactSpell, {__index = BaseSpell})
BloodPactSpell.__index = BloodPactSpell

function BloodPactSpell:new(caster, target, spellData, anim)
    local spell = BaseSpell:new(caster, target, spellData, anim)
    spell.x = target.renderer.x
    spell.y = target.renderer.y
    spell:playOnce()
    return setmetatable(spell, self)
end

function BloodPactSpell:onStart()
    local player = self.caster.player
    player:applyEffect(BloodPactEffect:new(player, 1))
end