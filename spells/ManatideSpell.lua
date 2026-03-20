require "spells.BaseSpell"
require "effects.ManaRegenEffect"

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
    local player = self.caster.player
    player:applyEffect(ManaRegenEffect:new(self.spellData.effectName, player, self.spellData.duration, self.spellData.regenAmount))
end
