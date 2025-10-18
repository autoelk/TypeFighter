require "spells.BaseSpell"

-- Abstract class for projectile-based spells
ProjectileSpell = {}
setmetatable(ProjectileSpell, { __index = BaseSpell })
ProjectileSpell.__index = ProjectileSpell

function ProjectileSpell:new(caster, target, spellData, anim)
    local spell = BaseSpell:new(caster, target, spellData, anim)
    setmetatable(spell, self)
    return spell
end

function ProjectileSpell:update(dt)
    BaseSpell.update(self, dt)

    -- Move the projectile towards the target
    local directionX = self.endX - self.startX
    local directionY = self.endY - self.startY
    local distance = math.sqrt(directionX ^ 2 + directionY ^ 2)
    if distance > 0 then
        local normX = directionX / distance
        local normY = directionY / distance

        self.x = self.x + normX * self.speedX * dt
        self.y = self.y + normY * self.speedY * dt
    end
end
