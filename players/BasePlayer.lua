BasePlayer = {}
BasePlayer.__index = BasePlayer

-- Player positioning constants
local PLAYER_POSITIONS = {
    [1] = {
        x = 100,
        y = 330,
        uiHealthX = 25,
        uiManaX = 25,
        textAlign = "left",
        textOffsetX = 30,
        animX = 100
    },
    [2] = {
        x = 700,
        y = 330,
        uiHealthX = 775,
        uiManaX = 775,
        textAlign = "right",
        textOffsetX = -25,
        mirror = true,
        animX = 540
    }
}

function BasePlayer:new(playerNumber)
    local player = {
        num = playerNumber,
        picks = 5,
        health = 50,
        isAlive = true,
        healthRegen = 0,
        mana = 0,
        manaRegen = 1,
        spriteNum = 1,
        anim = resourceManager:newAnimation(resourceManager:getImage("wizard"), 32, 32, 2),
        deathAnimStarted = false,
        deathAnimFinished = false,

        damageDisplay = {
            amount = 0,
            endTime = 0,
            isActive = false
        },
        effects = {}
    }
    setmetatable(player, self)
    return player
end

function BasePlayer:Draw()
    if self.isAlive then
        self.spriteNum = 1
    else
        self.spriteNum = self.anim.currentFrame or #self.anim.quads
    end

    local pos = PLAYER_POSITIONS[self.num]
    if pos.mirror then
        lg.draw(self.anim.spriteSheet, self.anim.quads[self.spriteNum], pos.x, pos.y, 0, -5, 5)
    else
        lg.draw(self.anim.spriteSheet, self.anim.quads[self.spriteNum], pos.x, pos.y, 0, 5, 5)
    end
end

function BasePlayer:DrawUI()
    local pos = PLAYER_POSITIONS[self.num]
    local healthSize = self.health * 2
    local manaSize = self.mana * 2

    -- Player 1 is left aligned
    -- Player 2 is right aligned
    local healthX = pos.uiHealthX
    local manaX = pos.uiManaX
    if self.num == 2 then
        healthX = healthX - healthSize
        manaX = manaX - manaSize
    end

    -- Draw mana bar
    lg.setColor(colors.blue)
    lg.rectangle("fill", manaX, 75, manaSize, 30)

    -- Draw health bar with color based on health level
    if self.health <= 10 then
        lg.setColor(colors.red)
        lg.rectangle("fill", healthX, 25, healthSize, 30)
        lg.setColor(colors.white)
    elseif self.health <= 20 then
        lg.setColor(colors.yellow)
        lg.rectangle("fill", healthX, 25, healthSize, 30)
        lg.setColor(colors.black)
    else
        lg.setColor(colors.green)
        lg.rectangle("fill", healthX, 25, healthSize, 30)
        lg.setColor(colors.white)
    end

    -- Draw health and mana text
    lg.setFont(fontL)
    lg.printf(math.floor(self.health + 0.5), pos.textOffsetX, 15, 800, pos.textAlign)
    lg.setColor(colors.white)
    lg.printf(math.floor(self.mana), pos.textOffsetX, 65, 800, pos.textAlign)

    -- Draw damage numbers
    self:drawDamageNumbers()
end

function BasePlayer:drawDamageNumbers()
    if self.damageDisplay.isActive and gameTime < self.damageDisplay.endTime and self.damageDisplay.amount ~= 0 then
        if self.damageDisplay.amount > 0 then
            lg.setColor(colors.red)
        else
            lg.setColor(colors.green)
        end

        local absAmount = math.abs(self.damageDisplay.amount)
        if absAmount > 20 then
            lg.setFont(fontXL)
        elseif absAmount > 10 then
            lg.setFont(fontL)
        else
            lg.setFont(fontM)
        end

        local pos = PLAYER_POSITIONS[self.num]
        local damageX, damageWidth
        if self.num == 1 then
            damageX = 70
            damageWidth = 200
        else
            damageX = 500
            damageWidth = 200
        end
        local damageY = 230 - (gameTime - self.damageDisplay.endTime) * 25

        lg.printf(absAmount, damageX, damageY, damageWidth, "center")
    end
end

function BasePlayer:Other()
    return gameManager:getOpponent(self)
end

function BasePlayer:Cast(cardIndex)
    local card = cards[cardIndex]

    -- Check if we are able to cast the card
    local canCast, errorMessage = card:canCast(self, self:Other())
    if not canCast then
        if not self.suppressMessages then
            message = errorMessage
        end
        if errorMessage == "that card is not in your deck" then
            return "not_your_card"
        elseif errorMessage == "you don't have enough mana" then
            return "insufficient_mana"
        else
            -- For other conditions like health requirements
            return "cannot_cast"
        end
    end

    -- Calculate animation position
    local x
    if card.loc == "self" then
        x = PLAYER_POSITIONS[self.num].animX
    elseif card.loc == "proj" then
        x = PLAYER_POSITIONS[self:Other().num].animX
    elseif card.loc == "other" then
        x = PLAYER_POSITIONS[self:Other().num].animX
    end
    card:PlayOnce(x, 300)

    -- Deduct mana cost
    self.mana = self.mana - card.mana
    if not self.suppressMessages then
        message2 = "player " .. self.num .. " cast " .. card.name
    end

    -- Use the card's cast method
    card:cast(self, self:Other())
    return "success"
end

function BasePlayer:Damage(amtDamage)
    -- Update damage display state
    self.damageDisplay.amount = amtDamage
    self.damageDisplay.endTime = gameTime + 1
    self.damageDisplay.isActive = true

    -- Apply damage to health
    self.health = self.health - amtDamage
    self.isAlive = self.health > 0
end

function BasePlayer:update(dt)
    local anim = self.anim
    -- Hold first frame while alive
    if self.isAlive then
        anim.currentFrame = 1
        anim.accumulator = 0
        self.deathAnimStarted = false
        self.deathAnimFinished = false
    elseif not self.deathAnimStarted then
        self.deathAnimStarted = true
        anim.currentFrame = 1
        anim.accumulator = 0
    elseif self.deathAnimFinished then
        anim.currentFrame = #anim.quads
        return
    end

    anim.accumulator = anim.accumulator + dt
    while anim.accumulator >= anim.frameDuration do
        anim.accumulator = anim.accumulator - anim.frameDuration
        anim.currentFrame = (anim.currentFrame or 1) + 1
        if anim.currentFrame >= #anim.quads then
            anim.currentFrame = #anim.quads
            self.deathAnimFinished = true
            break
        end
    end
    self:UpdateEffects(dt)
end

function BasePlayer:ApplyEffect(id, cfg)
    if not cfg then
        error("ApplyEffect requires a configuration table")
    end

    --[[ three modes: stack, refresh, ignore
    stack - refresh duration and add a stack, up to maxStacks
    refresh - refresh duration only
    ignore - do nothing if effect already exists ]]
    local eff = self.effects[id]
    if eff then
        local mode = cfg.stackMode or eff.stackMode or "refresh"
        if mode == "stack" then
            local newStacks = eff.stacks + 1
            if (cfg.maxStacks or eff.maxStacks) then
                local limit = cfg.maxStacks or eff.maxStacks
                newStacks = math.min(limit, newStacks)
                eff.maxStacks = limit
            end
            eff.stacks = newStacks
            eff.timeLeft = cfg.duration or eff.timeLeft
        elseif mode == "refresh" then
            eff.timeLeft = cfg.duration or eff.timeLeft
        elseif mode == "ignore" then
            return eff
        end
        return eff
    end

    eff = {
        id = id,
        timeLeft = cfg.duration,
        tickInterval = cfg.tickInterval,
        tickTimer = 0,
        stacks = 1,
        maxStacks = cfg.maxStacks,
        stackMode = cfg.stackMode or "refresh",
        onTick = cfg.onTick,
        onExpire = cfg.onExpire,
        onApply = cfg.onApply
    }
    self.effects[id] = eff
    if eff.onApply then
        eff.onApply(self, eff)
    end
    return eff
end

function BasePlayer:UpdateEffects(dt)
    for id, eff in pairs(self.effects) do
        if eff.timeLeft then
            eff.timeLeft = eff.timeLeft - dt
            if eff.timeLeft <= 0 then
                if eff.onExpire then
                    eff.onExpire(self, eff)
                end
                self.effects[id] = nil
            else
                if eff.tickInterval then
                    eff.tickTimer = eff.tickTimer + dt
                    while eff.tickTimer >= eff.tickInterval do
                        eff.tickTimer = eff.tickTimer - eff.tickInterval
                        if eff.onTick then
                            eff.onTick(self, eff)
                        end
                    end
                end
            end
        end
    end
end

function BasePlayer:HasEffect(id)
    return self.effects[id] ~= nil
end

function BasePlayer:GetEffect(id)
    return self.effects[id]
end

function BasePlayer:canAfford(manaCost)
    return self.mana >= manaCost
end
