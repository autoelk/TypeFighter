require "spells.BaseSpell"

SliceSpell = {}
setmetatable(SliceSpell, { __index = BaseSpell })
SliceSpell.__index = SliceSpell

function SliceSpell:new(caster, target, spellData, anim)
    local spell = BaseSpell:new(caster, target, spellData, anim)
    spell.x = target.x
    spell.y = target.y
    spell:playOnce()
    return setmetatable(spell, self)
end

function SliceSpell:onFinish()
    local dmg = math.floor(self.target.player.health * self.spellData.ratio)
    self.target:damage(dmg)
end
