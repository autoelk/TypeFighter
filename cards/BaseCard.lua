local CastResult = require "enums.CastResult"
local Keyword = require "enums.Keyword"

-- Base Card class that all cards inherit from
BaseCard = {}
BaseCard.__index = BaseCard
BaseCard.characterColors = {
    wizard = COLORS.BLUE,
    vampire = COLORS.RED
}

function BaseCard:new(ctx, x, y)
    if not ctx then
        error("BaseCard:new(ctx, x, y) requires ctx")
    end
    local card = {
        ctx = ctx,
        x = x,
        y = y,

        -- Attributes to be set by subclasses
        name = nil,
        incantationLength = nil,
        character = nil, -- string name of character this card belongs to
        color = nil,
        anim = nil,
        SpellClass = nil,
        spellData = {}, -- list of data for the spell this card casts, such as damage
        keywords = {}, -- list of keywords this card has
    }
    setmetatable(card, self)
    return card
end

function BaseCard:getColor()
    return self.color or COLORS.GREY
end

function BaseCard:setCharacter(characterName)
    self.character = characterName
    self.color = BaseCard.characterColors[characterName] or COLORS.WHITE
end

function BaseCard:getDescription()
    error("BaseCard:getDescription() must be implemented by subclass")
end

-- Check if we are able to cast the card, returns failure reason if not
function BaseCard:canCast(caster)
    return CastResult.Success
end

-- Draw large version of card
function BaseCard:draw()
    local margin = 8
    -- Draw background
    lg.setColor(self:getColor())
    lg.rectangle("fill", self.x, self.y, LARGE_CARD_WIDTH, LARGE_CARD_HEIGHT)
    lg.setColor(COLORS.WHITE)
    lg.rectangle("fill", self.x + margin, self.y + 32, SPRITE_SIZE, SPRITE_SIZE)

    -- Animate spell preview
    local spriteNum = math.min(math.max(1, self.anim.currentFrame), #self.anim.quads)
    lg.draw(self.anim.spriteSheet, self.anim.quads[spriteNum], self.x + margin, self.y + 32, math.rad(self.anim.rotation),
        self.anim.scaleX, self.anim.scaleY)

    -- Print text onto card
    local fonts = self.ctx.fonts
    lg.setFont(fonts.fontM)
    lg.printf(self.name, self.x + margin, self.y, LARGE_CARD_WIDTH, "left")
    lg.printf(self.incantationLength, self.x - margin, self.y, LARGE_CARD_WIDTH, "right")
    lg.setFont(fonts.fontS)
    lg.printf(self:getDescription(), self.x + margin, self.y + SPRITE_SIZE + margin * 2 + 16, SPRITE_SIZE, "left")
end

-- Draw mini version of card
function BaseCard:drawMini()
    local fonts = self.ctx.fonts
    lg.setColor(self:getColor())
    lg.rectangle("fill", self.x, self.y, MINI_CARD_WIDTH, MINI_CARD_HEIGHT)
    -- print text
    local margin = 4
    lg.setColor(COLORS.BLACK)
    lg.setFont(fonts.fontM)
    lg.printf(self.name, self.x + margin, self.y - 4, MINI_CARD_WIDTH, "left")
    lg.printf(self.incantationLength, self.x - margin, self.y - 4, MINI_CARD_WIDTH, "right")
    lg.setFont(fonts.fontS)
    lg.printf(self:getDescription(), self.x + margin, self.y + 20, MINI_CARD_WIDTH - margin * 2, "left")
end

-- Draw short description of keywords beside the card
function BaseCard:drawKeywords(x, y, maxWidth)
    local font = self.ctx.fonts.fontS
    local margin = 4
    lg.setFont(font)
    for _, keyword in ipairs(self.keywords) do
        local text = "[" .. keyword .. "] " .. Keyword.descriptions[keyword]
        local width, wrappedtext = font:getWrap( text, maxWidth )
        local height = #wrappedtext * (font:getHeight() * font:getLineHeight())
        lg.setColor(COLORS.GREY)
        lg.rectangle("fill", x, y, width + margin * 2, height + margin * 2)
        lg.setColor(COLORS.WHITE)
        lg.printf(text, x + margin, y, maxWidth, "left")
        y = y + height + margin * 3
    end
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

-- Smoothly move card to new position, if destination is too close, set to destination
function BaseCard:move(destX, destY)
    self:setPosition(math.abs(self.x - destX) < 1 and destX or self.x + ((destX - self.x) / 20),
        math.abs(self.y - destY) < 1 and destY or self.y + ((destY - self.y) / 20))
end

function BaseCard:cast(caster, target)
    local spellAnim = self.ctx.resourceManager:newAnimation("card_" .. self.name)
    spellAnim.playMode = "once"
    local spell = self.SpellClass:new(caster, target, self.spellData, spellAnim)
    spell:onStart()
    return spell
end
