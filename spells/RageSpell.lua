require "spells.ProjectileSpell"

RageSpell = {}
setmetatable(RageSpell, { __index = ProjectileSpell })
RageSpell.__index = RageSpell

function RageSpell:new(caster, target, spellData, anim)
    local spell = ProjectileSpell:new(caster, target, spellData, anim)
    spell.startX = caster.x
    spell.startY = caster.y
    spell.endX = target.x
    spell.endY = target.y

    spell.x = spell.startX
    spell.y = spell.startY
    spell.anim.offsetY = 15
    spell:playOnce()
    spell.speedX = math.abs(spell.endX - spell.startX) / anim.timeLeft
    spell.speedY = math.abs(spell.endY - spell.startY) / anim.timeLeft
    return setmetatable(spell, self)
end

function RageSpell:onStart()
    self.caster:damage(self.spellData.healthCost)
end

function RageSpell:onFinish()
    self.target:damage(self.spellData.damage)
end
