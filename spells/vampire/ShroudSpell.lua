require "spells.BaseSpell"

ShroudSpell = {}
setmetatable(ShroudSpell, {__index = BaseSpell})
ShroudSpell.__index = ShroudSpell

function ShroudSpell:new(caster, target, spellData, anim)
    local spell = BaseSpell:new(caster, target, spellData, anim)
    spell.x = caster.renderer.x
    spell.y = caster.renderer.y
    spell:playOnce()
    return setmetatable(spell, self)
end

function ShroudSpell:onStart()
    self.caster.player:addShield(self.spellData.shieldAmount)
end