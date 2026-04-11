require "spells.BaseSpell"

BlockSpell = {}
setmetatable(BlockSpell, {
    __index = BaseSpell
})
BlockSpell.__index = BlockSpell

function BlockSpell:new(caster, target, spellData, anim)
    local spell = BaseSpell:new(caster, target, spellData, anim)
    spell.x = caster.renderer.x
    spell.y = caster.renderer.y
    spell:playOnce()
    return setmetatable(spell, self)
end

function BlockSpell:onStart()
    self.caster.player:addShield(self.spellData.shieldAmount)
end