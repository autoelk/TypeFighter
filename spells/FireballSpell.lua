require "spells.ProjectileSpell"

FireballSpell = {}
setmetatable(FireballSpell, { __index = ProjectileSpell })
FireballSpell.__index = FireballSpell

function FireballSpell:new(caster, target, spellData, anim)
    local spell = ProjectileSpell:new(caster, target, spellData, anim)
    spell.startX = caster.x
    spell.startY = caster.y
    spell.endX = target.x
    spell.endY = target.y

    spell.x = spell.startX
    spell.y = spell.startY
    spell:playOnce()
    spell.speedX = math.abs(spell.endX - spell.startX) / anim.timeLeft
    spell.speedY = math.abs(spell.endY - spell.startY) / anim.timeLeft
    setmetatable(spell, self)
    return spell
end

function FireballSpell:onFinish()
    self.target:damage(self.spellData.damage)
end
