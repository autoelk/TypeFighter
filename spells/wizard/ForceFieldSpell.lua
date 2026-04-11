require "spells.BaseSpell"

ForceFieldSpell = {}
setmetatable(ForceFieldSpell, { __index = BaseSpell })
ForceFieldSpell.__index = ForceFieldSpell

function ForceFieldSpell:new(caster, target, spellData, anim)
    local spell = BaseSpell:new(caster, target, spellData, anim)
    spell.x = caster.renderer.x
    spell.y = caster.renderer.y
    spell:playOnce()
    return setmetatable(spell, self)
end

function ForceFieldSpell:onStart()
    self.caster.player:addShield(self.spellData.shieldAmount)
end