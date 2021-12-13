Card = {}

Card.__index = Card

function Card:Create(cardIndex)
  local inputTable = split(io.read(), " ")
  local card = {
    x = 0,
    y = 0,
    r = 0, -- rotation of the card
    s = 1,
    t = 0, -- time
    name = inputTable[1],
    damage = tonumber(inputTable[2]),
    mana = tonumber(inputTable[3]),
    type = inputTable[4],
    elem = inputTable[5],
    index = cardIndex,
    deck = 0
  }
  -- find and create card animation
  if fileCheck("assets/cards/" .. card.name .. ".png") then
    card.anim = newAnimation(love.graphics.newImage("assets/cards/" .. card.name .. ".png"), 160, 160, 1)
  else
    card.anim = newAnimation(love.graphics.newImage("assets/placeholder.png"), 160, 160, 10)
  end

  card.loc = inputTable[6] -- where the card is animated (proj, other, self)

  local cardText = ""
  for i = 7, #inputTable do
    cardText = cardText .. " " .. inputTable[i]
  end
  card.text = cardText

  setmetatable(card, self)
  return card
end

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
  XSFont:setLineHeight(0.6)
  love.graphics.setColor(self:Color())
  love.graphics.rectangle("fill", x, y, 130, 60)
  --print text
  love.graphics.setColor(colors.black)
  love.graphics.setFont(SFont)
  love.graphics.printf(self.name, x + 5, y, 130, "left")
  love.graphics.printf(self.mana, x - 5, y, 130, "right")
  love.graphics.setFont(XSFont)
  local cardText = ""
  if self.type == "attack" then
    cardText = "Deal " .. self.damage .. " damage."
  elseif self.type == "heal" then
    cardText = "Gain " .. self.damage .. " life."
  elseif self.type == "misc" then
    cardText = self.text
  end
  love.graphics.printf(cardText, x + 5, y + 15, 110, "left")
end

-- display large version of card during card selection
function Card:Display()
  if self.deck == 2 then
    love.graphics.setColor(self:Color())
    love.graphics.rectangle("fill", self.x, self.y, 180, 252)
    love.graphics.setColor(colors.black)
    love.graphics.rectangle("fill", self.x + 10, self.y + 25, 160, 160)
  else
    love.graphics.setColor(self:Color())
    love.graphics.rectangle("fill", self.x, self.y, 180, 252)
    love.graphics.setColor(colors.white)
    love.graphics.rectangle("fill", self.x + 10, self.y + 25, 160, 160)
  end
  --print text
  love.graphics.setFont(SFont)
  love.graphics.printf(self.name, self.x + 10, self.y, 180, "left")
  love.graphics.printf("mana " .. self.mana, self.x - 10, self.y, 180, "right")
  local cardText = ""
  if self.type == "attack" then
    cardText = "Deal " .. self.damage .. " damage."
  elseif self.type == "heal" then
    cardText = "Gain " .. self.damage .. " life."
  elseif self.type == "misc" then
    cardText = self.text
  end
  love.graphics.printf(cardText, self.x + 10, self.y + 190, 160, "left")
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
  love.graphics.setColor(colors.white)
  local spriteNum = math.floor(self.anim.currentTime / self.anim.duration * #self.anim.quads) + 1
  love.graphics.draw(self.anim.spriteSheet, self.anim.quads[spriteNum], x, y, r, s, 1)
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
