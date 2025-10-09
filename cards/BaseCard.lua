-- Base Card class that all cards inherit from
BaseCard = {}
BaseCard.__index = BaseCard

function BaseCard:new(cardData)
    local card = {
        x = cardData.x or 0,
        y = cardData.y or 0,
        t = 0, -- time for animations
        name = cardData.name,
        mana = cardData.mana or 0,
        type = cardData.type,
        elem = cardData.elem or "neutral",
        index = cardData.index,
        deck = 0,
        loc = cardData.loc or "self", -- where card is animated (proj, other, self)
        anim = cardData.anim,

        -- Animation configuration (fixed 12fps system)
        playMode = cardData.playMode or "loop",   -- loop | once | loop_for
        playTime = cardData.playTime,             -- only used if playMode == loop_for (seconds)
        offsetX = cardData.offsetX or 0,          -- X offset for animation positioning
        offsetY = cardData.offsetY or 0,          -- Y offset for animation positioning
        rotation = cardData.rotation or 0,        -- Default rotation for the card
        scale = cardData.scale or PIXEL_TO_GAME_SCALE -- Default scale for the card
    }
    setmetatable(card, self)
    return card
end

function BaseCard:color()
    if self.elem == "fire" then
        return COLORS.RED
    elseif self.elem == "earth" then
        return COLORS.GREEN
    elseif self.elem == "water" then
        return COLORS.BLUE
    else
        return COLORS.GREY
    end
end

-- Display mini version of card during gameplay
function BaseCard:displayMini(x, y)
    x = x or self.x
    y = y or self.y
    fontXS:setLineHeight(0.6)
    lg.setColor(self:color())
    lg.rectangle("fill", x, y, MINI_CARD_WIDTH, MINI_CARD_HEIGHT)
    -- print text
    lg.setColor(COLORS.BLACK)
    lg.setFont(fontS)
    lg.printf(self.name, x + 5, y, MINI_CARD_WIDTH, "left")
    lg.printf(self.mana, x - 5, y, MINI_CARD_WIDTH, "right")
    lg.setFont(fontXS)
    lg.printf(self:getDescription(), x + 5, y + 15, 110, "left")
end

-- Display large version of card during card selection
function BaseCard:display()
    if self.deck == 2 then
        lg.setColor(self:color())
        lg.rectangle("fill", self.x, self.y, LARGE_CARD_WIDTH, LARGE_CARD_HEIGHT)
        lg.setColor(COLORS.BLACK)
        lg.rectangle("fill", self.x + 10, self.y + 25, SCALED_SPRITE_SIZE, SCALED_SPRITE_SIZE)
    else
        lg.setColor(self:color())
        lg.rectangle("fill", self.x, self.y, LARGE_CARD_WIDTH, LARGE_CARD_HEIGHT)
        lg.setColor(COLORS.WHITE)
        lg.rectangle("fill", self.x + 10, self.y + 25, SCALED_SPRITE_SIZE, SCALED_SPRITE_SIZE)
    end

    -- print text
    lg.setFont(fontS)
    lg.printf(self.name, self.x + 10, self.y, LARGE_CARD_WIDTH, "left")
    lg.printf("mana " .. self.mana, self.x - 10, self.y, LARGE_CARD_WIDTH, "right")
    lg.printf(self:getDescription(), self.x + 10, self.y + 190, SCALED_SPRITE_SIZE, "left")
    self:animate(self.x + 10, self.y + 25)
end

function BaseCard:startAnimate(x, y, playMode, playTime)
    -- Reset animation timing
    self.anim.currentFrame = 1
    self.anim.accumulator = 0
    self.anim.elapsed = 0
    self.anim.loopMode = playMode or self.playMode or "loop"
    self.playMode = self.anim.loopMode
    self.playTime = playTime or self.playTime
    self.x = x or self.x
    self.y = y or self.y

    -- Determine active time window (self.t governs visibility in GameState:draw())
    if self.playMode == "once" then
        self.t = #self.anim.quads * self.anim.frameDuration
    elseif self.playMode == "loop_for" then
        self.t = self.playTime or (#self.anim.quads * self.anim.frameDuration)
    else -- loop (infinite)
        self.t = math.huge
    end
end

function BaseCard:animate(x, y, r, sx, sy, offsetX, offsetY)
    offsetX = offsetX or 0
    offsetY = offsetY or 0

    if self.deck == 2 then
        offsetX = -offsetX
    end

    local finalX = (x or self.x) + offsetX
    local finalY = (y or self.y) + offsetY

    r = r or self.rotation
    sx = sx or self.scale
    sy = sy or self.scale

    lg.setColor(COLORS.WHITE)

    local spriteNum = self.anim.currentFrame or 1
    if spriteNum < 1 then
        spriteNum = 1
    end
    if spriteNum > #self.anim.quads then
        spriteNum = #self.anim.quads
    end
    lg.draw(self.anim.spriteSheet, self.anim.quads[spriteNum], finalX, finalY, math.rad(r), sx, sy)
end

function BaseCard:update(dt)
    if self.t > 0 and self.t ~= math.huge then
        self.t = self.t - dt
        if self.t < 0 then
            self.t = 0
        end
    end

    -- Advance animation at fixed 12 fps
    local anim = self.anim
    if self.t > 0 then
        anim.accumulator = anim.accumulator + dt
        anim.elapsed = anim.elapsed + dt
        while anim.accumulator >= anim.frameDuration do
            anim.accumulator = anim.accumulator - anim.frameDuration
            anim.currentFrame = (anim.currentFrame or 1) + 1
            if anim.currentFrame > #anim.quads then
                if self.playMode == "once" then
                    self:resetAnimation()
                    anim.currentFrame = #anim.quads
                    break
                else
                    anim.currentFrame = 1
                end
            end
        end
        if self.playMode == "loop_for" and anim.elapsed >= (self.playTime or 0) then
            self:resetAnimation()
        end
    end
end

function BaseCard:playOnce(x, y)
    self:startAnimate(x, y, "once")
end

function BaseCard:loop(x, y)
    self:startAnimate(x, y, "loop")
end

function BaseCard:loopFor(x, y, seconds)
    self:startAnimate(x, y, "loop_for", seconds)
end

function BaseCard:resetAnimation()
    self.anim.currentFrame = 1
    self.anim.accumulator = 0
    self.anim.elapsed = 0
    self.t = 0
end

-- Calculate the location the card should be at
function BaseCard:move(dx, dy)
    if self.x ~= dx or self.y ~= dy then
        self.x = self.x + ((dx - self.x) / 20)
        self.y = self.y + ((dy - self.y) / 20)
    end
end

function BaseCard:getDescription()
    error("BaseCard:getDescription() must be implemented by subclass")
end

function BaseCard:cast(caster, target)
    error("BaseCard:cast() must be implemented by subclass")
end

-- Check if we are able to cast the card, returns failure reason if not
function BaseCard:canCast(caster, target)
    -- Check if caster owns this card
    if self.deck ~= caster.num then
        return false, "that card is not in your deck"
    end

    -- Check mana cost
    if not caster:canAfford(self.mana) then
        return false, "you don't have enough mana"
    end

    return true, nil
end
