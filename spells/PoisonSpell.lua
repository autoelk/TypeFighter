require "spells.BaseSpell"
require "effects.PoisonEffect"

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
    local player = self.target.player
    player:applyEffect(PoisonEffect:new(player, self.spellData.stacksToAdd))
end
