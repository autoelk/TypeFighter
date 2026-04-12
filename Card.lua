local CastResult = require "enums.CastResult"
local Keyword = require "enums.Keyword"
local Cards = require "definitions.Cards"

Card = {}
Card.__index = Card

function Card:new(ctx, name, x, y)
    if not ctx then
        error("Card:new(ctx, name, x, y) requires ctx")
    end
    local def = Cards[name]
    if not def then
        error("Unknown card: " .. tostring(name))
    end

    local previewKey = def.previewSprite or ("card_" .. name)
    local card = {
        ctx = ctx,
        x = x,
        y = y,
        name = name,
        incantationLength = def.incantationLength,
        character = def.character,
        color = nil,
        anim = ctx.resourceManager:newAnimation(previewKey, "loop"),
        SpellClass = def.spell,
        spellData = def.spellData,
        keywords = def.keywords or {},
        _describe = def.description,
    }
    setmetatable(card, self)
    return card
end

function Card:getColor()
    return self.color or COLORS.GREY
end

function Card:getDescription()
    return self._describe(self.spellData)
end

function Card:canCast(caster)
    return CastResult.Success
end

function Card:draw()
    local margin = 8
    lg.setColor(self:getColor())
    lg.rectangle("fill", self.x, self.y, LARGE_CARD_WIDTH, 32)
    lg.rectangle("fill", self.x, self.y + 32, margin, SPRITE_SIZE)
    lg.rectangle("fill", self.x + LARGE_CARD_WIDTH - margin, self.y + 32, margin, SPRITE_SIZE)
    lg.rectangle("fill", self.x, self.y + 32 + SPRITE_SIZE, LARGE_CARD_WIDTH, LARGE_CARD_HEIGHT - 32 - SPRITE_SIZE)
    lg.setColor({ 0, 0, 0, 0.5 })
    lg.rectangle("fill", self.x + margin, self.y + 32, SPRITE_SIZE, SPRITE_SIZE)

    lg.setColor(COLORS.WHITE)
    self.anim:draw(self.x + margin, self.y + 32)

    local fonts = self.ctx.fonts
    lg.setColor(COLORS.BLACK)
    lg.setFont(fonts.fontM)
    lg.printf(self.name, self.x + margin, self.y, LARGE_CARD_WIDTH, "left")
    lg.printf(self.incantationLength, self.x - margin, self.y, LARGE_CARD_WIDTH, "right")
    lg.setFont(fonts.fontS)
    lg.printf(self:getDescription(), self.x + margin, self.y + SPRITE_SIZE + margin * 2 + 16, SPRITE_SIZE, "left")
end

function Card:drawMini()
    local fonts = self.ctx.fonts
    lg.setColor(self:getColor())
    lg.rectangle("fill", self.x, self.y, MINI_CARD_WIDTH, MINI_CARD_HEIGHT)
    local margin = 4
    lg.setColor(COLORS.BLACK)
    lg.setFont(fonts.fontM)
    lg.printf(self.name, self.x + margin, self.y - 4, MINI_CARD_WIDTH, "left")
    lg.printf(self.incantationLength, self.x - margin, self.y - 4, MINI_CARD_WIDTH, "right")
    lg.setFont(fonts.fontS)
    lg.printf(self:getDescription(), self.x + margin, self.y + 20, MINI_CARD_WIDTH - margin * 2, "left")
end

function Card:drawKeywords(x, y, maxWidth)
    local font = self.ctx.fonts.fontS
    local margin = 4
    lg.setFont(font)
    for _, keyword in ipairs(self.keywords) do
        local text = "[" .. keyword .. "] " .. Keyword.descriptions[keyword]
        local width, wrappedtext = font:getWrap(text, maxWidth)
        local height = #wrappedtext * (font:getHeight() * font:getLineHeight())
        lg.setColor(COLORS.GREY)
        lg.rectangle("fill", x, y, width + margin * 2, height + margin * 2)
        lg.setColor(COLORS.WHITE)
        lg.printf(text, x + margin, y, maxWidth, "left")
        y = y + height + margin * 3
    end
end

function Card:update(dt)
    self.anim:update(dt)
end

function Card:setPosition(x, y)
    self.x = x
    self.y = y
end

function Card:move(destX, destY)
    self:setPosition(math.abs(self.x - destX) < 1 and destX or self.x + ((destX - self.x) / 20),
        math.abs(self.y - destY) < 1 and destY or self.y + ((destY - self.y) / 20))
end

function Card:cast(caster, target)
    local imageName = "card_" .. self.name
    if not self.ctx.resourceManager.images[imageName] then
        imageName = self.ctx.characterManager.characters[self.character].spellPlaceholderSprite
    end
    local spellAnim = self.ctx.resourceManager:newAnimation(imageName, "once")
    local spell = self.SpellClass:new(caster, target, self.spellData, spellAnim)
    spell:onStart()
    return spell
end
