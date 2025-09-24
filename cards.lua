Card = {}

Card.__index = Card

function Card:Color()
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

-- display mini version of card during gameplay
function Card:DisplayMini(x, y)
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
    local cardText = ""
    if self.type == "attack" then
        cardText = "Deal " .. self.damage .. " damage."
    elseif self.type == "heal" then
        cardText = "Gain " .. self.damage .. " life."
    elseif self.type == "misc" then
        cardText = self.text
    end
    lg.printf(cardText, x + 5, y + 15, 110, "left")
end

-- display large version of card during card selection
function Card:Display()
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
    local cardText = ""
    if self.type == "attack" then
        cardText = "Deal " .. self.damage .. " damage."
    elseif self.type == "heal" then
        cardText = "Gain " .. self.damage .. " life."
    elseif self.type == "misc" then
        cardText = self.text
    end
    lg.printf(cardText, self.x + 10, self.y + 190, 160, "left")
    self:Animate(self.x + 10, self.y + 25)
end

function Card:StartAnimate(x, y)
    self.anim.currentTime = 0 -- reset Animation
    self.x = x or self.x
    self.y = y or self.y
    self.t = self.anim.duration
end

function Card:Animate(x, y, r, s)
    x = x or self.x
    y = y or self.y
    if self.deck == 2 then
        s = -1
        x = x + 160
    end
    r = r or 0
    s = s or 1
    lg.setColor(colors.white)
    local spriteNum = math.floor(self.anim.currentTime / self.anim.duration * #self.anim.quads) + 1
    lg.draw(self.anim.spriteSheet, self.anim.quads[spriteNum], x, y, r, s, 1)
end

-- calculate the location the card should be at
function Card:Move(dx, dy)
    if self.x ~= dx or self.y ~= dy then
        self.x = self.x + ((dx - self.x) / 20)
        self.y = self.y + ((dy - self.y) / 20)
    end
end

-- find card in cards table, returns index
function findCard(cardToFind)
    cardToFind = string.lower(cardToFind)
    for i = 1, #cards do
        if cards[i].name == cardToFind then
            return i
        end
    end
    return 0
end
