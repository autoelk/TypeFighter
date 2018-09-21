Player = {}

Player.__index = Player

function Player:Create(number)
  local player = {
    num = number,
    picks = 5,
    maxMana = 50,
    maxHealth = 50,
    health = 50,
    mana = 0,
    manaRegen = 0
  }
  setmetatable(player, self)
  return player
end

function Player:Damage(amtDamage)
  self.health = self.health - amtDamage
end

function Player:Cast(index)
  -- if cards[index].deck == self.num then
    if cards[index].type == "attack" then
      message = "Player" .. self.num .. " cast " .. cards[index].name .. " and dealt " .. cards[index].damage .. " damage."
      self:Other():Damage(cards[index].damage)
    elseif cards[index].type == "heal" then
      message = "Player" .. self.num .. " cast " .. cards[index].name .. " and gained " .. cards[index].damage .. " life."
      self:Damage(-cards[index].damage)
    else
      message = "Player" .. self.num .. " cast " .. cards[index].name
    end
  -- end
end

function Player:Other()
  if self == player1 then
    return player2
  else
    return player1
  end
end
