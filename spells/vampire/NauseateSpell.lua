require "spells.BaseSpell"

NauseateSpell = {}
setmetatable(NauseateSpell, {
    __index = BaseSpell
})
NauseateSpell.__index = NauseateSpell

function NauseateSpell:new(caster, target, spellData, anim)
    local spell = BaseSpell:new(caster, target, spellData, anim)
    spell.x = target.renderer.x
    spell.y = target.renderer.y
    spell.anim.offsetY = -36
    spell:playOnce()
    return setmetatable(spell, self)
end

function NauseateSpell:onStart()
    local bleedEffect = self.target.player.effects["bleed"]
    if not bleedEffect then
        return
    end
    local stacks = bleedEffect.stacks
    local player = self.target.player
    player:applyEffect(FocusEffect:new(player, -stacks))
end