require "spells.BaseSpell"

PunchSpell = {}
setmetatable(PunchSpell, { __index = BaseSpell })
PunchSpell.__index = PunchSpell

function PunchSpell:new(caster, target, spellData, anim)
    local spell = BaseSpell:new(caster, target, spellData, anim)
    spell.x = target.x
    spell.y = target.y
    spell.anim.offsetX = -90
    spell.anim.offsetY = 15
    spell:playOnce()
    return setmetatable(spell, self)
end

function PunchSpell:onStart()
    self.target:damage(self.spellData.damage)
end
