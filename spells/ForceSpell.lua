require "spells.BaseSpell"

ForceSpell = {}
setmetatable(ForceSpell, { __index = BaseSpell })
ForceSpell.__index = ForceSpell

function ForceSpell:new(caster, target, spellData, anim)
    local spell = BaseSpell:new(caster, target, spellData, anim)
    spell.x = caster.x
    spell.y = caster.y
    spell:playOnce()
    setmetatable(spell, self)
    return spell
end

function ForceSpell:onStart()
    self.caster.manaRegen = self.caster.manaRegen - self.spellData.tradeAmount
    self.caster.healthRegen = self.caster.healthRegen + self.spellData.tradeAmount
end
