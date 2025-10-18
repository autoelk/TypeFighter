require "spells.BaseSpell"

TyphoonSpell = {}
setmetatable(TyphoonSpell, { __index = BaseSpell })
TyphoonSpell.__index = TyphoonSpell

function TyphoonSpell:new(caster, target, spellData, anim)
    local spell = BaseSpell:new(caster, target, spellData, anim)
    spell.x = target.x
    spell.y = target.y
    spell:playOnce()
    return setmetatable(spell, self)
end

function TyphoonSpell:onFinish()
    self.target:damage(self.spellData.damage)
end
