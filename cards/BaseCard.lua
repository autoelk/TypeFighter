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
        
        -- Animation configuration
        animSpeed = cardData.animSpeed or 1.0,  -- Speed multiplier for animation playback
        offsetX = cardData.offsetX or 0,        -- X offset for animation positioning
        offsetY = cardData.offsetY or 0,        -- Y offset for animation positioning
        rotation = cardData.rotation or 0,      -- Default rotation for the card
        scale = cardData.scale or 1             -- Default scale for the card
    }
    setmetatable(card, self)
    return card
end

function BaseCard:Color()
    if self.elem == "fire" then
        return colors.red
    elseif self.elem == "earth" then
        return colors.green
    elseif self.elem == "water" then
        return colors.blue
    else
        return colors.grey
    end
end

-- Display mini version of card during gameplay
function BaseCard:DisplayMini(x, y)
    x = x or self.x
    y = y or self.y
    fontXS:setLineHeight(0.6)
    lg.setColor(self:Color())
    lg.rectangle("fill", x, y, 130, 60)
    --print text
    lg.setColor(colors.black)
    lg.setFont(fontS)
    lg.printf(self.name, x + 5, y, 130, "left")
    lg.printf(self.mana, x - 5, y, 130, "right")
    lg.setFont(fontXS)
    lg.printf(self:getDescription(), x + 5, y + 15, 110, "left")
end

-- Display large version of card during card selection
function BaseCard:Display()
    if self.deck == 2 then
        lg.setColor(self:Color())
        lg.rectangle("fill", self.x, self.y, 180, 252)
        lg.setColor(colors.black)
        lg.rectangle("fill", self.x + 10, self.y + 25, 160, 160)
    else
        lg.setColor(self:Color())
        lg.rectangle("fill", self.x, self.y, 180, 252)
        lg.setColor(colors.white)
        lg.rectangle("fill", self.x + 10, self.y + 25, 160, 160)
    end

    --print text
    lg.setFont(fontS)
    lg.printf(self.name, self.x + 10, self.y, 180, "left")
    lg.printf("mana " .. self.mana, self.x - 10, self.y, 180, "right")
    lg.printf(self:getDescription(), self.x + 10, self.y + 190, 160, "left")
    self:Animate(self.x + 10, self.y + 25)
end

function BaseCard:StartAnimate(x, y)
    self.anim.currentTime = 0 -- reset Animation
    self.x = x or self.x
    self.y = y or self.y
    -- Adjust animation duration based on speed (faster speed = shorter duration)
    self.t = self.anim.duration / self.animSpeed
end

function BaseCard:Animate(x, y, r, s, offsetX, offsetY)
    -- Use provided offsets or default to 0 (no offset)
    offsetX = offsetX or 0
    offsetY = offsetY or 0
    
    local finalX = (x or self.x) + offsetX
    local finalY = (y or self.y) + offsetY
    
    r = r or self.rotation
    s = s or self.scale
    
    lg.setColor(colors.white)
    
    -- Calculate sprite frame based on animation speed
    local effectiveTime = self.anim.currentTime * self.animSpeed
    local spriteNum = math.floor(effectiveTime / self.anim.duration * #self.anim.quads) + 1
    
    -- Ensure spriteNum stays within bounds when using different animation speeds
    if spriteNum > #self.anim.quads then
        spriteNum = ((spriteNum - 1) % #self.anim.quads) + 1
    end
    
    lg.draw(self.anim.spriteSheet, self.anim.quads[spriteNum], finalX, finalY, r, s, 1)
end

-- Calculate the location the card should be at
function BaseCard:Move(dx, dy)
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