require "spells.BaseSpell"
require "effects.BleedEffect"

BiteSpell = {}
setmetatable(BiteSpell, { __index = BaseSpell })
BiteSpell.__index = BiteSpell

function BiteSpell:new(caster, target, spellData, anim)
    local spell = BaseSpell:new(caster, target, spellData, anim)
    spell.x = target.renderer.x
    spell.y = target.renderer.y
    spell.anim.offsetX = -48
    spell:playOnce()
    return setmetatable(spell, self)
end

function BiteSpell:onStart()
    local player = self.target.player
    player:damage(self.spellData.damage)
    player:applyEffect(BleedEffect:new(player, self.spellData.bleedAmount))
end