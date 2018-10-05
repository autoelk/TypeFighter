Player = {}

Player.__index = Player

function Player:Create(number)
  local player = {
    num = number,
    picks = 5,
    health = 50,
    healthRegen = 0,
    mana = 0,
    manaRegen = 1,
    spriteNum = 1,
    anim = newAnimation(love.graphics.newImage("Assets/Wizard.png"), 160, 160, 2)
  }
  setmetatable(player, self)
  return player
end

function Player:Damage(amtDamage)
  self.health = self.health - amtDamage
end

function Player:Draw()
  if self.health <= 0 and self.spriteNum ~= #self.anim.quads then
    self.spriteNum = math.floor(self.anim.currentTime / self.anim.duration * #self.anim.quads) + 1
  end

  if self.num == 1 then
    love.graphics.draw(self.anim.spriteSheet, self.anim.quads[self.spriteNum], 100, 330, 0)
  elseif self.num == 2 then
    love.graphics.draw(self.anim.spriteSheet, self.anim.quads[self.spriteNum], 700, 330, 0, - 1, 1)
  end
end

function Player:DrawUI()
  local heatlhX = 25
  local manaX = 25
  local healthSize = self.health * 2
  local manaSize = self.mana * 2
  if self.num == 2 then
    heatlhX = 800 - (healthSize + 25)
    manaX = 800 - (manaSize + 25)
  end
  love.graphics.setColor(colors.blue)
  love.graphics.rectangle("fill", manaX, 75, manaSize, 30)
  if self.health <= 10 then
    love.graphics.setColor(colors.red)
    love.graphics.rectangle("fill", heatlhX, 25, healthSize, 30)
    love.graphics.setColor(colors.white)
  elseif self.health <= 20 then
    love.graphics.setColor(colors.yellow)
    love.graphics.rectangle("fill", heatlhX, 25, healthSize, 30)
    love.graphics.setColor(colors.black)
  else
    love.graphics.setColor(colors.green)
    love.graphics.rectangle("fill", heatlhX, 25, healthSize, 30)
    love.graphics.setColor(colors.white)
  end
  love.graphics.setFont(uiFont)
  if self == player1 then
    love.graphics.printf(math.floor(self.health + 0.5), 30, 15, 800, "left")
    love.graphics.setColor(colors.white)
    love.graphics.printf(math.floor(self.mana), 30, 65, 800, "left")
  elseif self == opp then
    love.graphics.printf(math.floor(self.health + 0.5), - 25, 15, 800, "right")
    love.graphics.setColor(colors.white)
    love.graphics.printf(math.floor(self.mana), - 25, 65, 800, "right")
  end
end

function Player:Cast(i)
  if cards[i].deck == self.num then
    if self.mana >= cards[i].mana then
      self.mana = self.mana - cards[i].mana
      message2 = "Player" .. self.num .. " cast " .. cards[i].name
      if cards[i].type == "attack" then
        self:Other():Damage(cards[i].damage)
      elseif cards[i].type == "heal" then
        self:Damage(-cards[i].damage)
      elseif cards[i].type == "misc" then
        if cards[i].name == "gem" then
          self.manaRegen = self.manaRegen + cards[i].damage
        elseif cards[i].name == "doubleedge" then
          if self.health > cards[i].damage then
            self:Other():Damage(cards[i].damage)
          end
        elseif cards[i].name == "blessing" then
          self.healthRegen = self.healthRegen + cards[i].damage
        elseif cards[i].name == "poison" then
          self:Other().healthRegen = self:Other().healthRegen - cards[i].damage
        elseif cards[i].name == "manatide" then
          self.mana = self.mana * 2
        elseif cards[i].name == "force" then
          self.manaRegen = self.manaRegen - cards[i].damage
          self.healthRegen = self.healthRegen + cards[i].damage
        elseif cards[i].name == "ritual" then
          self.mana = self.mana + 30
          self.health = self.health - cards[i].damage
        elseif cards[i].name == "rage" then
          self:Other():Damage(50 - self.health)
        end
      end
    else
      message = "you don't have enough mana"
    end
  end
end

function Player:Other()
  if self == player1 then
    return opp
  else
    return player1
  end
end
