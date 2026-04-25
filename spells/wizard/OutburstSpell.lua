require "spells.BaseSpell"

OutburstSpell = {}
setmetatable(OutburstSpell, { __index = BaseSpell })
OutburstSpell.__index = OutburstSpell

function OutburstSpell:new(caster, target, spellData, anim)
    local spell = BaseSpell:new(caster, target, spellData, anim)
    spell.x = target.renderer.x
    spell.y = target.renderer.y
    spell:playOnce()
    return setmetatable(spell, self)
end

function OutburstSpell:onStart()
    local player = self.target.player
    local incantation = self.caster.incantation
    player:damage(self.spellData.damage * math.floor(#incantation / self.spellData.chars))
end