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
    if self.anim.playMode ~= "loop" then
        self.anim.timeLeft = self.anim.timeLeft - dt
    end

    self.anim.accumulator = self.anim.accumulator + dt
    while self.anim.accumulator >= self.anim.frameDuration do
        self.anim.accumulator = self.anim.accumulator - self.anim.frameDuration
        self.anim.currentFrame = self.anim.currentFrame + 1

        if self.anim.currentFrame > #self.anim.quads then
            if self.anim.playMode == "once" then
                self.anim.currentFrame = #self.anim.quads
                break
            else
                self.anim.currentFrame = 1
            end
        end
    end

    if self.anim.timeLeft <= 0 then
        self:onFinish()
    end
end

function BaseSpell:draw()
    lg.setColor(COLORS.WHITE)

    local x = self.x
    local offsetX = self.anim.offsetX
    local scaleX = self.anim.scaleX
    if self.caster:isMirrored() then
        x = self.x + SPRITE_SIZE
        offsetX = -offsetX
        scaleX = -math.abs(scaleX)
    end

    local spriteNum = math.min(math.max(1, self.anim.currentFrame), #self.anim.quads)
    lg.draw(self.anim.spriteSheet, self.anim.quads[spriteNum],
        x + offsetX, self.y + self.anim.offsetY,
        math.rad(self.anim.rotation), scaleX, self.anim.scaleY)
end

function BaseSpell:startAnimation(playMode, duration)
    self.anim.playMode = playMode
    if self.anim.playMode == "once" then
        self.anim.timeLeft = #self.anim.quads * self.anim.frameDuration
    elseif self.anim.playMode == "loop_for" then
        if not duration then
            error("Duration must be provided for loop_for play mode")
        end
        self.anim.timeLeft = duration
    elseif self.anim.playMode == "loop" then
        self.anim.timeLeft = math.huge
    end
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
