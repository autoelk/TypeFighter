require "spells.BaseSpell"
require "effects.FocusEffect"

GemSpell = {}
setmetatable(GemSpell, { __index = BaseSpell })
GemSpell.__index = GemSpell

function GemSpell:new(caster, target, spellData, anim)
    local spell = BaseSpell:new(caster, target, spellData, anim)
    spell.x = caster.renderer.x
    spell.y = caster.renderer.y
    spell:playOnce()
    return setmetatable(spell, self)
end

function GemSpell:onStart()
    local player = self.caster.player
    player:applyEffect(FocusEffect:new(player, self.spellData.focusAmount))
end