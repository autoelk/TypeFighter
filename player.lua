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
        manaRegen = 0,
        spriteNum = 1,
        anim = newAnimation(love.graphics.newImage("Assets/Wizard.png"), 160, 160, 1)
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
        love.graphics.draw(self.anim.spriteSheet, self.anim.quads[self.spriteNum], 700, 330, 0, -1, 1)
    end
end

function Player:DrawUI()
    local x = 0
    local healthSize = self.health * 2
    if self.num == 1 then
        x = 25
    else
        x = 800 - (healthSize + 25)
    end
    if self.health <= 10 then
        love.graphics.setColor(colors.red)
        love.graphics.rectangle("fill", x, 25, healthSize, 30)
        love.graphics.setColor(colors.white)
    elseif self.health <= 20 then
        love.graphics.setColor(colors.yellow)
        love.graphics.rectangle("fill", x, 25, healthSize, 30)
        love.graphics.setColor(colors.black)
    else
        love.graphics.setColor(colors.green)
        love.graphics.rectangle("fill", x, 25, healthSize, 30)
        love.graphics.setColor(colors.white)
    end
    love.graphics.setFont(uiFont)
    if self == player1 then
        love.graphics.printf(self.health, 30, 20, 800, "left")
    elseif self == opp then
        love.graphics.printf(self.health, -25, 20, 800, "right")
    end
end

function Player:Cast(index)
    if cards[index].deck == self.num then
        if cards[index].type == "attack" then
            message = "Player" .. self.num .. " cast " .. cards[index].name .. " and dealt " .. cards[index].damage .. " damage."
            self:Other():Damage(cards[index].damage)
        elseif cards[index].type == "heal" then
            message = "Player" .. self.num .. " cast " .. cards[index].name .. " and gained " .. cards[index].damage .. " life."
            self:Damage(-cards[index].damage)
        else
            message = "Player" .. self.num .. " cast " .. cards[index].name
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
