require "spells.BaseSpell"

HealSpell = {}
setmetatable(HealSpell, { __index = BaseSpell })
HealSpell.__index = HealSpell

function HealSpell:new(caster, target, spellData, anim)
    local spell = BaseSpell:new(caster, target, spellData, anim)
    spell.x = caster.x
    spell.y = caster.y
    spell:playOnce()
    return setmetatable(spell, self)
end

function HealSpell:onStart()
    self.caster:damage(-self.spellData.healAmount)
end
