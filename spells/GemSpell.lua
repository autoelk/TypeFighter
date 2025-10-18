require "spells.BaseSpell"

GemSpell = {}
setmetatable(GemSpell, { __index = BaseSpell })
GemSpell.__index = GemSpell

function GemSpell:new(caster, target, spellData, anim)
    local spell = BaseSpell:new(caster, target, spellData, anim)
    spell.x = caster.x
    spell.y = caster.y
    spell.anim.offsetY = -100
    spell:playOnce()
    return setmetatable(spell, self)
end

function GemSpell:onStart()
    self.caster.manaRegen = self.caster.manaRegen + self.spellData.regenAmount
end
