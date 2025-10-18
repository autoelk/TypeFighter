require "spells.ProjectileSpell"

TorrentSpell = {}
setmetatable(TorrentSpell, { __index = ProjectileSpell })
TorrentSpell.__index = TorrentSpell

function TorrentSpell:new(caster, target, spellData, anim)
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
    return setmetatable(spell, self)
end

function TorrentSpell:onFinish()
    self.target:damage(self.spellData.damage)
    self.caster:drawCard()
end
