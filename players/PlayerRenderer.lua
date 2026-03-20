-- View class for a player
PlayerRenderer = {}
PlayerRenderer.__index = PlayerRenderer

function PlayerRenderer:new(ctx, player)
    local renderer = {
        ctx = ctx,
        player = player,

        x = nil,
        y = nil,

        mirror = nil,
        tint = player.character.tint,

        idleAnim = ctx.resourceManager:newAnimation(player.character.idleSprite),
        castAnim = ctx.resourceManager:newAnimation(player.character.castSprite),
        deathAnim = ctx.resourceManager:newAnimation(player.character.deathSprite),
        isCasting = false,
        castAnimFinished = false,

        uiX = nil,
        textOffsetX = nil,
        libraryX = nil,
        libraryY = (MINI_CARD_HEIGHT + 10) * (MAX_HAND_SIZE + 1) + 160,
        deckX = nil,

        damageDisplay = {
            amount = 0,
            timeLeft = 0,
            isActive = false
        }
    }
    return setmetatable(renderer, self)
end

function PlayerRenderer:reset()
    self.isCasting = false

    self.deathAnim.currentFrame = 1
    self.deathAnim.accumulator = 0
    self.castAnim.currentFrame = 1
    self.castAnim.accumulator = 0
    self.idleAnim.currentFrame = 1
    self.idleAnim.accumulator = 0

    self.damageDisplay = {
        amount = 0,
        timeLeft = 0,
        isActive = false
    }
end

function PlayerRenderer:isMirrored()
    return self.mirror
end

function PlayerRenderer:showDamage(amount)
    self.damageDisplay.amount = amount
    self.damageDisplay.timeLeft = 1.0
    self.damageDisplay.isActive = true
end

function PlayerRenderer:startCastAnimation()
    self.isCasting = true
    self.castAnim.currentFrame = 1
    self.castAnim.accumulator = 0
end

function PlayerRenderer:draw(viewProps)
    viewProps = viewProps or {}
    self:drawChar()
    self:drawDamageDisplay()
    self:drawHealthAndManaBars()
    self:drawEffectsList()
    self:drawHand()
    self:drawLibrary(viewProps.drawWord)
end

function PlayerRenderer:drawChar()
    lg.setColor(self.tint)
    local scaleX = PIXEL_TO_GAME_SCALE
    local x = self.x
    if self.mirror then
        scaleX = -PIXEL_TO_GAME_SCALE
        x = self.x + SPRITE_SIZE
    end

    if not self.player.isAlive then
        lg.draw(self.deathAnim.spriteSheet, self.deathAnim.quads[self.deathAnim.currentFrame], x, self.y, 0, scaleX,
            PIXEL_TO_GAME_SCALE)
    elseif self.isCasting then
        lg.draw(self.castAnim.spriteSheet, self.castAnim.quads[self.castAnim.currentFrame], x, self.y, 0, scaleX,
            PIXEL_TO_GAME_SCALE)
    else
        lg.draw(self.idleAnim.spriteSheet, self.idleAnim.quads[self.idleAnim.currentFrame], x, self.y, 0, scaleX,
            PIXEL_TO_GAME_SCALE)
    end
end

-- Display damage or healing above the character
function PlayerRenderer:drawDamageDisplay()
    -- TODO: Make multiple damage numbers visible at the same time
    if not self.damageDisplay.isActive then
        return
    end

    if self.damageDisplay.amount > 0 then
        lg.setColor(COLORS.RED)
    else
        lg.setColor(COLORS.GREEN)
    end

    local absAmount = math.abs(self.damageDisplay.amount)
    local fonts = self.ctx.fonts
    if absAmount > 20 then
        lg.setFont(fonts.fontXL)
    elseif absAmount > 10 then
        lg.setFont(fonts.fontL)
    else
        lg.setFont(fonts.fontM)
    end

    local damageY = self.y - 55 + self.damageDisplay.timeLeft * 40
    lg.printf(absAmount, self.x, damageY, SPRITE_SIZE, "center")
end

function PlayerRenderer:drawHealthAndManaBars()
    local barScale = 2
    local healthSize = self.player.health * barScale
    local manaSize = self.player.mana * barScale

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
    if self.player.health <= 10 then
        lg.setColor(COLORS.RED)
        lg.rectangle("fill", healthX, 25, healthSize, 30)
        lg.setColor(COLORS.WHITE)
    elseif self.player.health <= 20 then
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
    lg.setFont(self.ctx.fonts.fontL)
    lg.printf(math.ceil(self.player.health), self.textOffsetX, 15, GAME_WIDTH, textAlign)
    lg.setColor(COLORS.WHITE)
    lg.printf(math.floor(self.player.mana), self.textOffsetX, 65, GAME_WIDTH, textAlign)
end

function PlayerRenderer:drawEffectsList()
    local stackEffects = self:drawStackEffectsHelper()
    local durationEffects = self:drawDurationEffectsHelper()
    local effects = {}
    table.move(stackEffects, 1, #stackEffects, 1, effects)
    table.move(durationEffects, 1, #durationEffects, 1 + #stackEffects, effects)

    local textAlign = "left"
    local baseX = self.x
    local baseY = self.y + SPRITE_SIZE + 8

    lg.setFont(self.ctx.fonts.fontS)
    for i, effect in ipairs(effects) do
        local label = effect.name
        if effect.type == "stack" then
            label = label .. " x" .. math.floor(effect.stacks)
        elseif effect.type == "duration" and effect.timeLeft ~= nil then
            label = label .. " (" .. math.max(0, math.ceil(effect.timeLeft)) .. "s)"
        end

        local y = baseY + (i - 1) * 16
        lg.setColor(COLORS.WHITE)
        lg.printf(label, baseX, y, SPRITE_SIZE, textAlign)
    end
end

function PlayerRenderer:drawStackEffectsHelper()
    local stackEffects = {}
    for _, effect in pairs(self.player.stackEffects) do
        local eff = {
            name = effect.name,
            stacks = effect.stacks,
            type = effect.type
        }
        table.insert(stackEffects, eff)
    end

    -- Sort effects by stacks left, then by name
    table.sort(stackEffects, function(a, b)
        if a.stacks == b.stacks then
            return a.name < b.name
        else 
            return a.stacks > b.stacks
        end
    end)

    return stackEffects
end

function PlayerRenderer:drawDurationEffectsHelper()
    local durationEffects = {}
    for _, effect in pairs(self.player.durationEffects) do
        local eff = {
            name = effect.name,
            timeLeft = effect.timeLeft,
            type = effect.type
        }
        table.insert(durationEffects, eff)
    end

    -- Sort effects by time left, then by name
    table.sort(durationEffects, function(a, b)
        if a.timeLeft == b.timeLeft then
            return a.name < b.name
        else 
            return a.timeLeft > b.timeLeft
        end
    end)

    return durationEffects
end

-- Draw cards in hand as mini cards
function PlayerRenderer:drawHand()
    for i, card in ipairs(self.player.hand) do
        card:drawMini()
    end
end

-- Draw library with draw word or card back
function PlayerRenderer:drawLibrary(drawWord)
    local fonts = self.ctx.fonts

    if #self.player.hand >= MAX_HAND_SIZE then
        lg.setColor(COLORS.GREY)
        lg.rectangle("fill", self.libraryX, self.libraryY, MINI_CARD_WIDTH, MINI_CARD_HEIGHT)
        lg.setColor(COLORS.WHITE)
        lg.setFont(fonts.fontL)
        lg.printf("hand full", self.libraryX, self.libraryY + 5, MINI_CARD_WIDTH, "center")
    else
        lg.setColor(COLORS.YELLOW)
        lg.rectangle("fill", self.libraryX, self.libraryY, MINI_CARD_WIDTH, MINI_CARD_HEIGHT)
        lg.setColor(COLORS.BLACK)
        if drawWord ~= nil then
            -- For human, show the draw word
            lg.setFont(fonts.fontS)
            lg.printf("type", self.libraryX, self.libraryY, MINI_CARD_WIDTH, "center")
            lg.setFont(fonts.fontL)
            lg.printf(drawWord, self.libraryX, self.libraryY + 5, MINI_CARD_WIDTH, "center")
            lg.setFont(fonts.fontS)
            lg.printf("to draw", self.libraryX, self.libraryY + 35, MINI_CARD_WIDTH, "center")
        else
            -- For AI, just label as deck
            lg.setFont(fonts.fontL)
            lg.printf("DECK", self.libraryX, self.libraryY + 5, MINI_CARD_WIDTH, "center")
        end
    end
end

-- Draw all cards in deck, only used in CardSelectScene
function PlayerRenderer:drawDeck()
    for i, card in ipairs(self.player.deck) do
        card:drawMini()
    end
end

function PlayerRenderer:update(dt)
    self:updateDamageDisplay(dt)
    self:updateCharAnimations(dt)
    self:updateHand(dt)
    self:updateLibrary(dt)
end

function PlayerRenderer:updateDamageDisplay(dt)
    if not self.damageDisplay.isActive then
        return
    end

    self.damageDisplay.timeLeft = self.damageDisplay.timeLeft - dt
    if self.damageDisplay.timeLeft <= 0 then
        self.damageDisplay.isActive = false
        self.damageDisplay.amount = 0
    end
end

function PlayerRenderer:updateCharAnimations(dt)
    if not self.player.isAlive then
        self.deathAnim.accumulator = self.deathAnim.accumulator + dt
        while self.deathAnim.accumulator >= self.deathAnim.frameDuration do
            self.deathAnim.accumulator = self.deathAnim.accumulator - self.deathAnim.frameDuration
            self.deathAnim.currentFrame = (self.deathAnim.currentFrame or 1) + 1
            -- Freeze on last frame
            if self.deathAnim.currentFrame >= #self.deathAnim.quads then
                self.deathAnim.currentFrame = #self.deathAnim.quads
                break
            end
        end
    elseif self.isCasting then
        self.castAnim.accumulator = self.castAnim.accumulator + dt
        while self.castAnim.accumulator >= self.castAnim.frameDuration do
            self.castAnim.accumulator = self.castAnim.accumulator - self.castAnim.frameDuration
            self.castAnim.currentFrame = (self.castAnim.currentFrame or 1) + 1
            if self.castAnim.currentFrame > #self.castAnim.quads then
                self.castAnim.currentFrame = #self.castAnim.quads
                self.isCasting = false
                break
            end
        end
    else
        self.idleAnim.accumulator = self.idleAnim.accumulator + dt
        while self.idleAnim.accumulator >= self.idleAnim.frameDuration do
            self.idleAnim.accumulator = self.idleAnim.accumulator - self.idleAnim.frameDuration
            self.idleAnim.currentFrame = (self.idleAnim.currentFrame or 1) + 1
            if self.idleAnim.currentFrame > #self.idleAnim.quads then
                self.idleAnim.currentFrame = 1
                break
            end
        end
    end
end

-- Update positions of cards in hand
function PlayerRenderer:updateHand(dt)
    local margin = 10
    for i, card in ipairs(self.player.hand) do
        card:move(self.libraryX, (MINI_CARD_HEIGHT + margin) * i + 100)
    end
end

function PlayerRenderer:updateLibrary(dt)
    for i, card in ipairs(self.player.library) do
        card:move(self.libraryX, self.libraryY)
    end
end

-- Update positions of cards in deck, only used in CardSelectScene
function PlayerRenderer:updateDeck(dt)
    local margin = 10
    for i, card in ipairs(self.player.deck) do
        card:move(self.deckX, (MINI_CARD_HEIGHT + margin) * i + 100)
    end
end