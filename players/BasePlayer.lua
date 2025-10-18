-- Abstract base class for players
BasePlayer = {}
BasePlayer.__index = BasePlayer

function BasePlayer:new(id)
    local player = {
        -- Basic stats
        id = id,
        isAlive = true,
        health = 50,
        healthRegen = 0,
        mana = 0,
        manaRegen = 1,
        effects = {},

        -- Cards
        picks = MAX_DECK_SIZE,
        hand = {},    -- Current cards in hand
        library = {}, -- All cards available to draw from
        deck = {},    -- All cards owned by the player

        -- Drawing
        x = nil,
        y = nil,
        idleAnim = nil,
        deathAnim = nil,
        castAnim = nil,
        isCasting = false,
        castAnimFinished = false,
        deathAnimStarted = false,
        deathAnimFinished = false,
        mirror = false,
        damageDisplay = {
            amount = 0,
            endTime = 0,
            isActive = false
        },
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
    self.deathAnim.currentFrame = 1
    self.deathAnim.accumulator = 0
    self.deathAnimStarted = false
    self.deathAnimFinished = false
    self.castAnim.currentFrame = 1
    self.castAnim.accumulator = 0
    self.idleAnim.currentFrame = 1
    self.idleAnim.accumulator = 0
    self.isCasting = false
    self.castAnimFinished = false
    self.damageDisplay = {
        amount = 0,
        endTime = 0,
        isActive = false
    }
    self.effects = {}
    self.hand = {}
end

function BasePlayer:draw()
    if not self.isAlive then
        lg.draw(self.deathAnim.spriteSheet, self.deathAnim.quads[self.deathAnim.currentFrame], self.x, self.y, 0,
            PIXEL_TO_GAME_SCALE,
            PIXEL_TO_GAME_SCALE)
    elseif self.isCasting and self.castAnim then
        lg.draw(self.castAnim.spriteSheet, self.castAnim.quads[self.castAnim.currentFrame], self.x, self.y, 0,
            PIXEL_TO_GAME_SCALE,
            PIXEL_TO_GAME_SCALE)
    else
        lg.draw(self.idleAnim.spriteSheet, self.idleAnim.quads[self.idleAnim.currentFrame], self.x, self.y, 0,
            PIXEL_TO_GAME_SCALE,
            PIXEL_TO_GAME_SCALE)
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

        local damageY = self.y - 40 - (gameTime - self.damageDisplay.endTime) * 25
        lg.printf(absAmount, self.x, damageY, SPRITE_SIZE, "center")
    end
end

function BasePlayer:castCard(card)
    -- Check if the card is in our hand
    local handIdx = indexOf(self.hand, card)

    if not handIdx then
        if not self.suppressMessages then
            message = "that card is not in your hand"
        end
        return "not_in_hand"
    end

    -- Check if we are able to cast the card
    local canCast, errorMessage = card:canCast(self, self:other())
    if not canCast then
        if not self.suppressMessages then
            message = errorMessage
        end
        if errorMessage == "you don't have enough mana" then
            return "insufficient_mana"
        else
            -- For other conditions like health requirements
            return "cannot_cast"
        end
    end

    -- Start casting animation
    self.isCasting = true
    self.castAnim.currentFrame = 1
    self.castAnim.accumulator = 0
    self.castAnimFinished = false

    -- Deduct mana cost
    self.mana = self.mana - card.mana
    if not self.suppressMessages then
        message2 = "player " .. self.id .. " cast " .. card.name
    end

    -- Remove card from hand
    table.remove(self.hand, handIdx)
    table.insert(self.library, card)

    -- Use the card's cast method
    local spell = card:cast(self, self:other())
    table.insert(sceneManager:getCurrentState().activeSpells, spell)
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
    -- Hold first frame while alive
    if self.isAlive then
        self.deathAnim.currentFrame = 1
        self.deathAnim.accumulator = 0
        self.deathAnimStarted = false
        self.deathAnimFinished = false
    elseif not self.deathAnimStarted then
        self.deathAnim.currentFrame = 1
        self.deathAnim.accumulator = 0
        self.deathAnimStarted = true
    elseif self.deathAnimFinished then
        self.deathAnim.currentFrame = #self.deathAnim.quads
        return
    end

    self.deathAnim.accumulator = self.deathAnim.accumulator + dt
    while self.deathAnim.accumulator >= self.deathAnim.frameDuration do
        self.deathAnim.accumulator = self.deathAnim.accumulator - self.deathAnim.frameDuration
        self.deathAnim.currentFrame = (self.deathAnim.currentFrame or 1) + 1
        if self.deathAnim.currentFrame >= #self.deathAnim.quads then
            self.deathAnim.currentFrame = #self.deathAnim.quads
            self.deathAnimFinished = true
            break
        end
    end

    self.castAnim.accumulator = self.castAnim.accumulator + dt
    while self.castAnim.accumulator >= self.castAnim.frameDuration do
        self.castAnim.accumulator = self.castAnim.accumulator - self.castAnim.frameDuration
        self.castAnim.currentFrame = (self.castAnim.currentFrame or 1) + 1
        if self.castAnim.currentFrame > #self.castAnim.quads then
            self.castAnim.currentFrame = #self.castAnim.quads
            self.isCasting = false
            self.castAnimFinished = true
            break
        end
    end

    self.idleAnim.accumulator = self.idleAnim.accumulator + dt
    while self.idleAnim.accumulator >= self.idleAnim.frameDuration do
        self.idleAnim.accumulator = self.idleAnim.accumulator - self.idleAnim.frameDuration
        self.idleAnim.currentFrame = (self.idleAnim.currentFrame or 1) + 1
        if self.idleAnim.currentFrame > #self.idleAnim.quads then
            self.idleAnim.currentFrame = 1
            break
        end
    end
    self:updateEffects(dt)
end

-- Add a card to the player's deck
function BasePlayer:addCard(card)
    table.insert(self.deck, card)
    self.picks = self.picks - 1
end

-- Remove a card from the player's deck
function BasePlayer:removeCard(card)
    local idx = indexOf(self.deck, card)
    if idx then
        table.remove(self.deck, idx)
        self.picks = self.picks + 1
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

function BasePlayer:drawCard()
    if #self.hand >= MAX_HAND_SIZE then
        return false
    end

    table.insert(self.hand, self.library[1])
    table.remove(self.library, 1)
    return true
end

function BasePlayer:canAfford(manaCost)
    return self.mana >= manaCost
end

function BasePlayer:other()
    error("BasePlayer:other() must be implemented by subclass")
end

function BasePlayer:isMirrored()
    return self.mirror
end

function indexOf(array, value)
    for i, v in ipairs(array) do
        if v == value then
            return i
        end
    end
    return nil
end
