require "spells.BaseSpell"

BoltSpell = {}
setmetatable(BoltSpell, { __index = BaseSpell })
BoltSpell.__index = BoltSpell

function BoltSpell:new(caster, target, spellData, anim)
    local spell = BaseSpell:new(caster, target, spellData, anim)
    spell.x = target.x
    spell.y = target.y
    spell:playOnce()
    return setmetatable(spell, self)
end

function BoltSpell:onStart()
    self.target:damage(self.spellData.damage)
end
