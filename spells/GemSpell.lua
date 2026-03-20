require "spells.BaseSpell"
require "effects.ManaRegenEffect"

GemSpell = {}
setmetatable(GemSpell, { __index = BaseSpell })
GemSpell.__index = GemSpell

function GemSpell:new(caster, target, spellData, anim)
    local spell = BaseSpell:new(caster, target, spellData, anim)
    spell.x = caster.renderer.x
    spell.y = caster.renderer.y
    spell.anim.offsetY = -100
    spell:playOnce()
    return setmetatable(spell, self)
end

function GemSpell:onStart()
    local player = self.caster.player
    player:applyEffect(ManaRegenEffect:new(self.spellData.effectName, player, nil, self.spellData.regenAmount))
end
