require "spells.BaseSpell"
require "effects.ShiftedEffect"

ShiftKeySpell = {}
setmetatable(ShiftKeySpell, {__index = BaseSpell})
ShiftKeySpell.__index = ShiftKeySpell

function ShiftKeySpell:new(caster, target, spellData, anim)
    local spell = BaseSpell:new(caster, target, spellData, anim)
    spell.x = target.renderer.x
    spell.y = target.renderer.y
    spell:playOnce()
    return setmetatable(spell, self)
end

function ShiftKeySpell:onStart()
    local player = self.target.player
    player:applyEffect(ShiftedEffect:new(player, self.spellData.stacks))
end