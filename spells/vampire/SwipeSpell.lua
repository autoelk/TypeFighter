require "spells.BaseSpell"

SwipeSpell = {}
setmetatable(SwipeSpell, { __index = BaseSpell })
SwipeSpell.__index = SwipeSpell

function SwipeSpell:new(caster, target, spellData, anim)
    local spell = BaseSpell:new(caster, target, spellData, anim)
    spell.x = target.renderer.x
    spell.y = target.renderer.y
    spell:playOnce()
    return setmetatable(spell, self)
end

function SwipeSpell:onFinish()
    self.target.player:damage(self.spellData.damage)
end