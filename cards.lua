Card = {}

Card.__index = Card

function Card:Create(cardIndex)
  local inputTable = split(io.read(), " ")
  local card = {
    name = inputTable[1],
    damage = tonumber(inputTable[2]),
    mana = tonumber(inputTable[3]),
    type = inputTable[4],
    elem = inputTable[5],
    index = cardIndex,
    deck = 0
  }
  if fileCheck("Assets/Cards/" .. card.name .. ".png") then
    card.anim = newAnimation(love.graphics.newImage("Assets/Cards/" .. card.name .. ".png"), 160, 160, 1)
  else
    card.anim = newAnimation(love.graphics.newImage("Assets/Placeholder.png"), 160, 160, 10)
  end
  local cardText = ""
  for i = 6, #inputTable do
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

function Card:DisplayMini(cardX, cardY)
  miniTextFont:setLineHeight(0.6)
  love.graphics.setColor(self:Color())
  love.graphics.rectangle("fill", cardX, cardY, 130, 60)
  --print text
  love.graphics.setColor(colors.black)
  love.graphics.setFont(cardTextFont)
  love.graphics.printf(self.name, cardX + 5, cardY, 130, "left")
  love.graphics.printf(self.mana, cardX - 5, cardY, 130, "right")
  love.graphics.setFont(miniTextFont)
  local cardText = ""
  if self.type == "attack" then
    cardText = "Deal " .. self.damage .. " damage."
  elseif self.type == "heal" then
    cardText = "Gain " .. self.damage .. " life."
  elseif self.type == "misc" then
    cardText = self.text
  end
  love.graphics.printf(cardText, cardX + 5, cardY + 15, 110, "left")
end

function Card:Display(cardX, cardY)
  if self.deck == 2 then
    -- elseif self.deck == 1 then
    --     love.graphics.setColor(self:Color())
    --     love.graphics.rectangle("fill", cardX, cardY, 180, 252)
    --     love.graphics.setColor(colors.black)
    --     love.graphics.rectangle("fill", cardX + 10, cardY + 25, 160, 160)
    love.graphics.setColor(colors.black)
    love.graphics.rectangle("fill", cardX, cardY, 180, 252)
    love.graphics.setColor(self:Color())
    love.graphics.rectangle("fill", cardX + 10, cardY + 25, 160, 160)
  else
    love.graphics.setColor(self:Color())
    love.graphics.rectangle("fill", cardX, cardY, 180, 252)
    love.graphics.setColor(colors.white)
    love.graphics.rectangle("fill", cardX + 10, cardY + 25, 160, 160)
  end
  --print text
  love.graphics.setFont(cardTextFont)
  love.graphics.printf(self.name, cardX + 10, cardY, 180, "left")
  love.graphics.printf("mana " .. self.mana, cardX - 10, cardY, 180, "right")
  local cardText = ""
  if self.type == "attack" then
    cardText = "Deal " .. self.damage .. " damage."
  elseif self.type == "heal" then
    cardText = "Gain " .. self.damage .. " life."
  elseif self.type == "misc" then
    cardText = self.text
  end
  love.graphics.printf(cardText, cardX + 10, cardY + 190, 160, "left")
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
