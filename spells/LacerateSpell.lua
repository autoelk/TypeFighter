require "spells.BaseSpell"
require "effects.BleedEffect"

LacerateSpell = {}
setmetatable(LacerateSpell, { __index = BaseSpell })
LacerateSpell.__index = LacerateSpell

function LacerateSpell:new(caster, target, spellData, anim)
    local spell = BaseSpell:new(caster, target, spellData, anim)
    spell.x = target.renderer.x
    spell.y = target.renderer.y
    spell:playOnce()
    return setmetatable(spell, self)
end

function LacerateSpell:onStart()
    local player = self.target.player
    player:applyEffect(BleedEffect:new(player, self.spellData.stacksToAdd))
end
