local CastResult = require "enums.CastResult"

-- Base Card class that all cards inherit from
BaseCard = {}
BaseCard.__index = BaseCard

function BaseCard:new(x, y)
    local card = {
        x = x,
        y = y,

        -- Attributes to be set by subclasses
        mana = nil,
        elem = nil,
        SpellClass = nil,
        spellData = nil,
        anim = nil
    }
    setmetatable(card, self)
    return card
end

function BaseCard:getColor()
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

function BaseCard:getDescription()
    error("BaseCard:getDescription() must be implemented by subclass")
end

-- Check if we are able to cast the card, returns failure reason if not
function BaseCard:canCast(caster)
    if not caster:cardInHand(self) then
        return CastResult.CardNotInHand
    end
    if not caster:canAfford(self.mana) then
        return CastResult.InsufficientMana
    end
    return CastResult.Success
end

-- Draw large version of card
function BaseCard:draw()
    -- Draw background
    lg.setColor(self:getColor())
    lg.rectangle("fill", self.x, self.y, LARGE_CARD_WIDTH, LARGE_CARD_HEIGHT)
    lg.setColor(COLORS.WHITE)
    lg.rectangle("fill", self.x + 10, self.y + 25, SPRITE_SIZE, SPRITE_SIZE)

    -- Animate spell preview
    local spriteNum = math.min(math.max(1, self.anim.currentFrame), #self.anim.quads)
    lg.draw(self.anim.spriteSheet, self.anim.quads[spriteNum], self.x + 10, self.y + 25, math.rad(self.anim.rotation),
        self.anim.scaleX, self.anim.scaleY)

    -- Print text onto card
    lg.setFont(fontS)
    lg.printf(self.name, self.x + 10, self.y, LARGE_CARD_WIDTH, "left")
    lg.printf("mana " .. self.mana, self.x - 10, self.y, LARGE_CARD_WIDTH, "right")
    lg.printf(self:getDescription(), self.x + 10, self.y + 190, SPRITE_SIZE, "left")
end

-- Draw mini version of card
function BaseCard:drawMini()
    fontXS:setLineHeight(0.6)
    lg.setColor(self:getColor())
    lg.rectangle("fill", self.x, self.y, MINI_CARD_WIDTH, MINI_CARD_HEIGHT)
    -- print text
    local margin = 5
    lg.setColor(COLORS.BLACK)
    lg.setFont(fontS)
    lg.printf(self.name, self.x + margin, self.y, MINI_CARD_WIDTH, "left")
    lg.printf(self.mana, self.x - margin, self.y, MINI_CARD_WIDTH, "right")
    lg.setFont(fontXS)
    lg.printf(self:getDescription(), self.x + margin, self.y + 15, MINI_CARD_WIDTH - 4 * margin, "left")
end

function BaseCard:update(dt)
    self.anim.accumulator = self.anim.accumulator + dt
    while self.anim.accumulator >= self.anim.frameDuration do
        self.anim.accumulator = self.anim.accumulator - self.anim.frameDuration
        self.anim.currentFrame = self.anim.currentFrame + 1

        if self.anim.currentFrame > #self.anim.quads then
            self.anim.currentFrame = 1
        end
    end
end

function BaseCard:setPosition(x, y)
    self.x = x
    self.y = y
end

-- Smoothly move card to new position
function BaseCard:move(destX, destY)
    self:setPosition(
        math.abs(self.x - destX) < 1 and destX or self.x + ((destX - self.x) / 20),
        math.abs(self.y - destY) < 1 and destY or self.y + ((destY - self.y) / 20)
    )
end

function BaseCard:cast(caster, target)
    local spellAnim = resourceManager:newAnimation("card_" .. self.name)
    spellAnim.playMode = "once"
    local spell = self.SpellClass:new(caster, target, self.spellData, spellAnim)
    spell:onStart()
    return spell
end
