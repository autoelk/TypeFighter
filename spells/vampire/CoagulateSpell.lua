require "spells.BaseSpell"

CoagulateSpell = {}
setmetatable(CoagulateSpell, {__index = BaseSpell})
CoagulateSpell.__index = CoagulateSpell

function CoagulateSpell:new(caster, target, spellData, anim)
    local spell = BaseSpell:new(caster, target, spellData, anim)
    spell.x = caster.renderer.x
    spell.y = caster.renderer.y
    spell:playOnce()
    return setmetatable(spell, self)
end

function CoagulateSpell:onStart()
    self.caster.player:damage(self.spellData.healthCost)
    self.caster.player:addShield(self.spellData.shieldAmount)
end