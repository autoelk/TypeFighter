-- Sprite sheet animation
Animation = {}
Animation.__index = Animation

function Animation:new(spriteSheet, width, height, fps)
    local fps = fps or 12
    local animation = {
        spriteSheet = spriteSheet,
        quads = {},

        -- timing
        frameDuration = 1 / fps,
        currentFrame = 1,
        accumulator = 0, -- time accumulated since last frame
        timeLeft = nil, -- time left
        duration = nil,
        playMode = "once", -- loop | once | loop_for

        -- constants
        width = width or SPRITE_PIXEL_SIZE,
        height = height or SPRITE_PIXEL_SIZE,
        rotation = 0, -- rotation in degrees
        scaleX = PIXEL_TO_GAME_SCALE,
        scaleY = PIXEL_TO_GAME_SCALE,
        offsetX = 0,
        offsetY = 0
    }

    animation.quads = {}
    for y = 0, animation.spriteSheet:getHeight() - animation.height, animation.height do
        for x = 0, animation.spriteSheet:getWidth() - animation.width, animation.width do
            table.insert(animation.quads, lg.newQuad(x, y, animation.width, animation.height, animation.spriteSheet:getDimensions()))
        end
    end

    return setmetatable(animation, self)
end

function Animation:reset()
    self.currentFrame = 1
    self.accumulator = 0
    self:setPlayMode(self.playMode, self.duration)
end

function Animation:getSpriteIndex()
    return math.min(math.max(1, self.currentFrame), #self.quads)
end

function Animation:draw(x, y, r, sx, sy)
    local r = r or self.rotation
    local sx = sx or self.scaleX
    local sy = sy or self.scaleY
    lg.draw(self.spriteSheet, self.quads[self:getSpriteIndex()], x, y, math.rad(r), sx, sy)
end


-- Update animation based on play mode.
-- loop: loop forever
-- loop_for: loop for duration, then stay there, returns true when done
-- once: advance to last frame, then stay there, returns true when done
function Animation:update(dt)
    if self.playMode ~= "loop" then
        self.timeLeft = self.timeLeft - dt
    end

    self.accumulator = self.accumulator + dt
    while self.accumulator >= self.frameDuration do
        self.accumulator = self.accumulator - self.frameDuration
        self.currentFrame = self.currentFrame + 1

        if self.currentFrame > #self.quads then
            if self.playMode == "once" then
                self.currentFrame = #self.quads
                self.timeLeft = 0
                break
            else
                self.currentFrame = 1
            end
        end
    end

    return self.timeLeft <= 0
end

function Animation:setPlayMode(playMode, duration)
    self.playMode = playMode
    if self.playMode == "once" then
        self.duration = #self.quads * self.frameDuration
        self.timeLeft = self.duration
    elseif self.playMode == "loop_for" then
        if not duration then
            error("Duration must be provided for loop_for play mode")
        end
        self.duration = duration
        self.timeLeft = self.duration
    elseif self.playMode == "loop" then
        self.timeLeft = math.huge
    end
end

function Animation:isFinished()
    return self.timeLeft <= 0
end