Card = {}

Card.__index = Card

function Card:Create(cardIndex)
  local tempTable = split(io.read(), " ")
  local card = {
    name = tempTable[1],
    damage = tempTable[2],
    mana = tempTable[3],
    type = tempTable[4],
    elem = tempTable[5],
    index = cardIndex,
    deck = 0
  }
  if fileCheck("Assets/Cards/" .. card.name .. ".png") then
    card.anim = newAnimation(love.graphics.newImage("Assets/Cards/" .. card.name .. ".png"), 160, 160, 1)
  else
    card.anim = newAnimation(love.graphics.newImage("Assets/Placeholder.png"), 160, 160, 1)
  end
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

function Card:Display()
  love.graphics.setFont(font)
  local colNum, rowNum = self.index % 3, math.ceil(self.index / 3)
  if colNum == 0 then
    colNum = 3
  end
  local cardX, cardY = 190 * (colNum - 1) + 10, 262 * (rowNum - 1) + posy

  if self.deck == 1 then
    love.graphics.setColor(colors.black)
    love.graphics.rectangle("fill", cardX, cardY, 180, 252)
    love.graphics.setColor(self:Color())
    love.graphics.rectangle("fill", cardX + 10, cardY + 25, 160, 160)
  elseif self.deck == 2 then
    love.graphics.setColor(self:Color())
    love.graphics.rectangle("fill", cardX, cardY, 180, 252)
    love.graphics.setColor(colors.black)
    love.graphics.rectangle("fill", cardX + 10, cardY + 25, 160, 160)
  else
    love.graphics.setColor(self:Color())
    love.graphics.rectangle("fill", cardX, cardY, 180, 252)
    love.graphics.setColor(colors.white)
    love.graphics.rectangle("fill", cardX + 10, cardY + 25, 160, 160)
  end
  --print text
  love.graphics.printf(self.name, cardX + 10, cardY, 180, "left")
  love.graphics.printf(self.mana, cardX - 10, cardY, 180, "right")
  local cardText = ""
  if self.type == "attack" then
    cardText = "Deal " .. self.damage .. " damage."
  elseif self.type == "heal" then
    cardText = "Gain " .. self.damage .. " life."
  end
  love.graphics.printf(cardText, cardX + 10, cardY + 200, 180, "left")
  --print images
  love.graphics.setColor(colors.white)
  local spriteNum = math.floor(self.anim.currentTime / self.anim.duration * #self.anim.quads) + 1
  love.graphics.draw(self.anim.spriteSheet, self.anim.quads[spriteNum], cardX + 10, cardY + 25, 0, 1)
end

function findCard(cardToFind)
  cardToFind = string.lower(cardToFind)
  for i = 1, numCards do
    if cards[i].name == cardToFind then
      return i
    end
  end
  return 0
end
