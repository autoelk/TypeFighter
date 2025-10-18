require "spells.BaseSpell"

RitualSpell = {}
setmetatable(RitualSpell, { __index = BaseSpell })
RitualSpell.__index = RitualSpell

function RitualSpell:new(caster, target, spellData, anim)
    local spell = BaseSpell:new(caster, target, spellData, anim)
    spell.x = caster.x
    spell.y = caster.y
    spell:playOnce()
    return setmetatable(spell, self)
end

function RitualSpell:onStart()
    self.caster:damage(self.spellData.healthCost)
    self.caster.mana = self.caster.mana + self.spellData.manaGain
end
