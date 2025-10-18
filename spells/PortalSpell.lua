require "spells.BaseSpell"

PortalSpell = {}
setmetatable(PortalSpell, { __index = BaseSpell })
PortalSpell.__index = PortalSpell

function PortalSpell:new(caster, target, spellData, anim)
    local spell = BaseSpell:new(caster, target, spellData, anim)
    spell.x = target.x
    spell.y = target.y
    spell:playOnce()
    return setmetatable(spell, self)
end

function PortalSpell:onStart()
    self.target:damage(self.spellData.damage)
end
