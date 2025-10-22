local CastResult = require "enums.CastResult"

-- Abstract controller class for players
BasePlayerController = {}
BasePlayerController.__index = BasePlayerController

function BasePlayerController:new(player)
    local controller = {
        player = player,
        isHuman = nil,
        opponent = nil,

        mirror = nil,
        tint = COLORS.WHITE,

        x = nil,
        y = nil,
        uiX = nil,
        textOffsetX = nil,
        libraryX = nil,
        libraryY = (MINI_CARD_HEIGHT + 10) * (MAX_HAND_SIZE + 1) + 160,
        deckX = nil,

        idleAnim = nil,
        deathAnim = nil,
        castAnim = nil,
        isCasting = false,
        castAnimFinished = false,

        damageDisplay = {
            amount = 0,
            timeLeft = 0,
            isActive = false
        }
    }
    return setmetatable(controller, self)
end

function BasePlayerController:reset()
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

    self.player:reset()
end

function BasePlayerController:isMirrored()
    return self.mirror
end

function BasePlayerController:getOpponent()
    if not self.opponent then
        error("Opponent not set for player controller")
    end
    return self.opponent
end

function BasePlayerController:setOpponent(opponentController)
    self.opponent = opponentController
end

function BasePlayerController:draw()
    self:drawChar()
    self:drawDamageDisplay()
    self:drawHealthAndManaBars()
    self:drawHand()
    self:drawLibrary()
end

function BasePlayerController:drawChar()
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
function BasePlayerController:drawDamageDisplay()
    if not self.damageDisplay.isActive then
        return
    end

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

    local damageY = self.y - 55 + self.damageDisplay.timeLeft * 40
    lg.printf(absAmount, self.x, damageY, SPRITE_SIZE, "center")
end

function BasePlayerController:drawHealthAndManaBars()
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
    lg.setFont(fontL)
    lg.printf(math.ceil(self.player.health), self.textOffsetX, 15, GAME_WIDTH, textAlign)
    lg.setColor(COLORS.WHITE)
    lg.printf(math.floor(self.player.mana), self.textOffsetX, 65, GAME_WIDTH, textAlign)
end

-- Draw cards in hand as mini cards
function BasePlayerController:drawHand()
    for i, card in ipairs(self.player.hand) do
        card:drawMini()
    end
end

-- Draw library with draw word or card back
function BasePlayerController:drawLibrary()
    error("BasePlayerController:drawLibrary() must be implemented by subclass")
end

-- Draw all cards in deck, only used in CardSelectScene
function BasePlayerController:drawDeck()
    for i, card in ipairs(self.player.deck) do
        card:drawMini()
    end
end

function BasePlayerController:update(dt)
    self:updateDamageDisplay(dt)
    self:updateCharAnimations(dt)
    self:updateHand(dt)
    self:updateLibrary(dt)

    self.player:update(dt)
end

-- Update positions of cards in hand
function BasePlayerController:updateHand(dt)
    local margin = 10
    for i, card in ipairs(self.player.hand) do
        card:move(self.libraryX, (MINI_CARD_HEIGHT + margin) * i + 100)
    end
end

function BasePlayerController:updateLibrary(dt)
    for i, card in ipairs(self.player.library) do
        card:move(self.libraryX, self.libraryY)
    end
end

-- Update positions of cards in deck, only used in CardSelectScene
function BasePlayerController:updateDeck(dt)
    local margin = 10
    for i, card in ipairs(self.player.deck) do
        card:move(self.deckX, (MINI_CARD_HEIGHT + margin) * i + 100)
    end
end

function BasePlayerController:updateDamageDisplay(dt)
    if not self.damageDisplay.isActive then
        return
    end

    self.damageDisplay.timeLeft = self.damageDisplay.timeLeft - dt
    if self.damageDisplay.timeLeft <= 0 then
        self.damageDisplay.isActive = false
        self.damageDisplay.amount = 0
    end
end

function BasePlayerController:updateCharAnimations(dt)
    if not self.player.isAlive then
        self.deathAnim.accumulator = self.deathAnim.accumulator + dt
        while self.deathAnim.accumulator >= self.deathAnim.frameDuration do
            self.deathAnim.accumulator = self.deathAnim.accumulator - self.deathAnim.frameDuration
            self.deathAnim.currentFrame = (self.deathAnim.currentFrame or 1) + 1
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

function BasePlayerController:damage(amt)
    self.damageDisplay.amount = amt
    self.damageDisplay.timeLeft = 1.0
    self.damageDisplay.isActive = true

    self.player:damage(amt)
end

function BasePlayerController:castCard(card)
    local castResult = card:canCast(self.player)
    if castResult == CastResult.Success then
        self.isCasting = true
        self.castAnim.currentFrame = 1
        self.castAnim.accumulator = 0
        self.player:castCard(card)
        local spell = card:cast(self, self:getOpponent())
        table.insert(sceneManager:getCurrentScene().activeSpells, spell)
    end
    return castResult
end

function BasePlayerController:drawCard()
    return self.player:drawCard()
end
