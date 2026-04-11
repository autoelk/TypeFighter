-- Abstract base Spell class that all spell cards inherit from
BaseSpell = {}
BaseSpell.__index = BaseSpell

function BaseSpell:new(caster, target, spellData, anim)
    local spell = {
        x = nil,
        y = nil,
        caster = caster,
        target = target,
        spellData = spellData,
        anim = anim
    }
    setmetatable(spell, self)
    return spell
end

function BaseSpell:update(dt)
    if self.anim:update(dt) then
        self:onFinish()
    end
end

function BaseSpell:draw()
    lg.setColor(COLORS.WHITE)

    local x = self.x
    local offsetX = self.anim.offsetX
    local scaleX = self.anim.scaleX
    if self.caster.renderer:isMirrored() then
        x = self.x + SPRITE_SIZE
        offsetX = -offsetX
        scaleX = -math.abs(scaleX)
    end

    self.anim:draw(x + offsetX, self.y + self.anim.offsetY, self.anim.rotation, scaleX, self.anim.scaleY)
end

function BaseSpell:startAnimation(playMode, duration)
    self.anim:setPlayMode(playMode, duration)
end

function BaseSpell:playOnce()
    self:startAnimation("once")
end

function BaseSpell:playLoop()
    self:startAnimation("loop")
end

function BaseSpell:playLoopFor(seconds)
    self:startAnimation("loop_for", seconds)
end

function BaseSpell:onStart()
    -- To be implemented by subclasses
end

function BaseSpell:onFinish()
    -- To be implemented by subclasses
end
