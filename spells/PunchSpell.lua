require "spells.BaseSpell"

PunchSpell = {}
setmetatable(PunchSpell, { __index = BaseSpell })
PunchSpell.__index = PunchSpell

function PunchSpell:new(caster, target, spellData, anim)
    local spell = BaseSpell:new(caster, target, spellData, anim)
    spell.x = target.renderer.x
    spell.y = target.renderer.y
    spell.anim.offsetX = -88
    spell.anim.offsetY = 16
    spell:playOnce()
    return setmetatable(spell, self)
end

function PunchSpell:onStart()
    self.target:damage(self.spellData.damage)
end
