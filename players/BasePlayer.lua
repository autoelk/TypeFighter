BasePlayer = {}
BasePlayer.__index = BasePlayer

function BasePlayer:new(id)
    local player = {
        id = id,
        picks = MAX_DECK_SIZE,
        health = 50,
        isAlive = true,
        healthRegen = 0,
        mana = 0,
        manaRegen = 1,
        spriteNum = 1,
        deck = {},
        anim = resourceManager:getAnimation("wizard"),
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

-- Reset player state for a new game, does not reset deck
function BasePlayer:reset()
    self.health = 50
    self.isAlive = true
    self.healthRegen = 0
    self.mana = 0
    self.manaRegen = 1
    self.spriteNum = 1
    self.anim.currentFrame = 1
    self.anim.accumulator = 0
    self.deathAnimStarted = false
    self.deathAnimFinished = false
    self.damageDisplay = {
        amount = 0,
        endTime = 0,
        isActive = false
    }
    self.effects = {}
end

function BasePlayer:draw()
    if self.isAlive then
        self.spriteNum = 1
    else
        self.spriteNum = self.anim.currentFrame or #self.anim.quads
    end

    if self.mirror then
        lg.draw(
            self.anim.spriteSheet,
            self.anim.quads[self.spriteNum],
            self.x,
            self.y,
            0,
            -PIXEL_TO_GAME_SCALE,
            PIXEL_TO_GAME_SCALE
        )
    else
        lg.draw(
            self.anim.spriteSheet,
            self.anim.quads[self.spriteNum],
            self.x,
            self.y,
            0,
            PIXEL_TO_GAME_SCALE,
            PIXEL_TO_GAME_SCALE
        )
    end
end

function BasePlayer:drawUI()
    local barScale = 2
    local healthSize = self.health * barScale
    local manaSize = self.mana * barScale

    local healthX = self.uiX
    local manaX = self.uiX
    if self.mirror then
        healthX = healthX - healthSize
        manaX = manaX - manaSize
    end

    -- Draw mana bar
    lg.setColor(COLORS.BLUE)
    lg.rectangle("fill", manaX, 75, manaSize, 30)

    -- Draw health bar with color based on health level
    if self.health <= 10 then
        lg.setColor(COLORS.RED)
        lg.rectangle("fill", healthX, 25, healthSize, 30)
        lg.setColor(COLORS.WHITE)
    elseif self.health <= 20 then
        lg.setColor(COLORS.YELLOW)
        lg.rectangle("fill", healthX, 25, healthSize, 30)
        lg.setColor(COLORS.BLACK)
    else
        lg.setColor(COLORS.GREEN)
        lg.rectangle("fill", healthX, 25, healthSize, 30)
        lg.setColor(COLORS.WHITE)
    end

    -- Draw health and mana text
    local textAlign = "left"
    if self.mirror then
        textAlign = "right"
    end
    lg.setFont(fontL)
    lg.printf(math.ceil(self.health), self.textOffsetX, 15, GAME_WIDTH, textAlign)
    lg.setColor(COLORS.WHITE)
    lg.printf(math.floor(self.mana), self.textOffsetX, 65, GAME_WIDTH, textAlign)

    -- Draw damage numbers
    self:drawDamageNumbers()
end

function BasePlayer:drawDamageNumbers()
    if self.damageDisplay.isActive and gameTime < self.damageDisplay.endTime and self.damageDisplay.amount ~= 0 then
        if self.damageDisplay.amount > 0 then
            lg.setColor(COLORS.RED)
        else
            lg.setColor(COLORS.GREEN)
        end

        local absAmount = math.abs(self.damageDisplay.amount)
        if absAmount > 20 then
            lg.setFont(fontXL)
        elseif absAmount > 10 then
            lg.setFont(fontL)
        else
            lg.setFont(fontM)
        end

        local damageX = self.x
        if self.mirror then
            damageX = damageX - SPRITE_SIZE
        end
        local damageY = self.animY - 40 - (gameTime - self.damageDisplay.endTime) * 25
        lg.printf(absAmount, damageX, damageY, SPRITE_SIZE, "center")
    end
end

function BasePlayer:castCard(cardIndex)
    local card = cards[cardIndex]

    -- Check if we are able to cast the card
    local canCast, errorMessage = card:canCast(self, self:other())
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
        x = self.animX
    elseif card.loc == "proj" then
        x = self:other().animX
    elseif card.loc == "other" then
        x = self:other().animX
    end
    card:playOnce(x, self.animY)

    -- Deduct mana cost
    self.mana = self.mana - card.mana
    if not self.suppressMessages then
        message2 = "player " .. self.id .. " cast " .. card.name
    end

    -- Use the card's cast method
    card:cast(self, self:other())
    return "success"
end

function BasePlayer:damage(amtDamage)
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
        anim.currentFrame = 1
        anim.accumulator = 0
        self.deathAnimStarted = true
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
    self:updateEffects(dt)
end

-- Add a card to the player's deck
function BasePlayer:addCard(cardIdx)
    cards[cardIdx].deck = self.id
    table.insert(self.deck, cardIdx)
    self.picks = self.picks - 1
end

-- Remove a card from the player's deck
function BasePlayer:removeCard(cardIdx)
    for i, v in ipairs(self.deck) do
        if v == cardIdx then
            cards[cardIdx].deck = 0
            table.remove(self.deck, i)
            self.picks = self.picks + 1
            return
        end
    end
end

function BasePlayer:applyEffect(id, cfg)
    if not cfg then
        error("applyEffect requires a configuration table")
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

function BasePlayer:updateEffects(dt)
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

function BasePlayer:canAfford(manaCost)
    return self.mana >= manaCost
end

function BasePlayer:other()
    error("BasePlayer:other() must be implemented by subclass")
end
