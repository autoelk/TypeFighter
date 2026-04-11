require "spells.BaseSpell"

SiphonSpell = {}
setmetatable(SiphonSpell, {
    __index = BaseSpell
})
SiphonSpell.__index = SiphonSpell

function SiphonSpell:new(caster, target, spellData, anim)
    local spell = BaseSpell:new(caster, target, spellData, anim)
    spell.x = target.renderer.x
    spell.y = target.renderer.y
    spell:playOnce()
    return setmetatable(spell, self)
end

function SiphonSpell:onStart()
    local bleedEffect = self.target.player.effects["bleed"]
    if not bleedEffect then
        return
    end
    local shieldAmount = bleedEffect.stacks
    self.caster.player:addShield(shieldAmount)
end