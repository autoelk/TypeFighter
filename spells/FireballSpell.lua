require "spells.ProjectileSpell"
require "effects.FocusEffect"

FireballSpell = {}
setmetatable(FireballSpell, { __index = ProjectileSpell })
FireballSpell.__index = FireballSpell

function FireballSpell:new(caster, target, spellData, anim)
    local spell = ProjectileSpell:new(caster, target, spellData, anim)
    spell.startX = caster.renderer.x
    spell.startY = caster.renderer.y
    spell.endX = target.renderer.x
    spell.endY = target.renderer.y

    spell.x = spell.startX
    spell.y = spell.startY
    spell:playOnce()
    spell.speedX = math.abs(spell.endX - spell.startX) / anim.timeLeft
    spell.speedY = math.abs(spell.endY - spell.startY) / anim.timeLeft
    setmetatable(spell, self)
    return spell
end

function FireballSpell:onStart()
    local player = self.caster.player
    player:applyEffect(FocusEffect:new(player, self.spellData.focusAmount))
end

function FireballSpell:onFinish()
    self.target.player:damage(self.spellData.damage)
end
