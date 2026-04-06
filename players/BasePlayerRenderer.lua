-- Abstract view class for a player
BasePlayerRenderer = {}
BasePlayerRenderer.__index = BasePlayerRenderer

function BasePlayerRenderer:new(ctx, player)
    local renderer = {
        ctx = ctx,
        player = player,

        x = nil,
        y = 408,

        mirror = nil,

        idleAnim = ctx.resourceManager:newAnimation(player.character.idleSprite),
        castAnim = ctx.resourceManager:newAnimation(player.character.castSprite),
        deathAnim = ctx.resourceManager:newAnimation(player.character.deathSprite),
        isCasting = false,
        castAnimFinished = false,

        damageDisplays = {}
    }
    return setmetatable(renderer, self)
end

function BasePlayerRenderer:reset()
    self.isCasting = false

    self.deathAnim.currentFrame = 1
    self.deathAnim.accumulator = 0
    self.castAnim.currentFrame = 1
    self.castAnim.accumulator = 0
    self.idleAnim.currentFrame = 1
    self.idleAnim.accumulator = 0

    self.damageDisplays = {}
end

function BasePlayerRenderer:isMirrored()
    return self.mirror
end

function BasePlayerRenderer:showDamage(amount)
    if amount == 0 then
        return
    end

    -- Red if damage, green if healing
    local color = COLORS.RED
    if amount < 0 then
        color = COLORS.GREEN
    end

    local absAmount = math.abs(amount)
    local font = self.ctx.fonts.fontM
    if absAmount > 20 then
        font = self.ctx.fonts.fontXL
    elseif absAmount > 10 then
        font = self.ctx.fonts.fontL
    end
    
    local duration = 1.0
    local maxInstances = 10

    table.insert(self.damageDisplays, 1, {
        amount = math.abs(amount),
        color = color,
        font = font,
        timeLeft = duration,
        duration = duration,
        xOffset = (love.math.random() - 0.5) * SPRITE_SIZE,
        yOffset = (love.math.random() - 0.5) * 8
    })

    while #self.damageDisplays > maxInstances do
        table.remove(self.damageDisplays)
    end
end

function BasePlayerRenderer:startCastAnimation()
    self.isCasting = true
    self.castAnim.currentFrame = 1
    self.castAnim.accumulator = 0
end

function BasePlayerRenderer:draw()
    self:drawChar()
    self:drawHealthBar()
    self:drawEffectsList()
    self:drawSelectedCard()
    self:drawDamageDisplay()
end

function BasePlayerRenderer:drawChar()
    lg.setColor(COLORS.WHITE)
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
function BasePlayerRenderer:drawDamageDisplay()
    if #self.damageDisplays == 0 then
        return
    end

    local fonts = self.ctx.fonts
    for i, display in ipairs(self.damageDisplays) do
        lg.setColor(display.color)
        lg.setFont(display.font)
        local progress = 0
        if display.duration > 0 then
            progress = 1 - (display.timeLeft / display.duration)
        end

        local baseY = self.y - 48
        local floatY = (1 - progress) * 40

        lg.printf(display.amount, self.x + display.xOffset, baseY + floatY + display.yOffset, SPRITE_SIZE, "center")
    end
end

function BasePlayerRenderer:drawHealthBar()
    --[[
    -- Draw vertical health bar
    local healthBarWidth = SPRITE_SIZE
    local healthBarHeight = math.ceil(SPRITE_SIZE * self.player.health / self.player.maxHealth)
    local healthBarX = self.x
    local healthBarY = self.y + (SPRITE_SIZE - healthBarHeight)

    lg.setColor(COLORS.GREEN)
    lg.rectangle("fill", healthBarX, healthBarY, healthBarWidth, healthBarHeight)
    --]]
    
    ---[[
    -- Draw horizontal health bar
    local healthBarWidth = math.ceil(SPRITE_SIZE * self.player.health / self.player.maxHealth)
    local healthBarHeight = 24
    local healthBarX = self.x
    local healthBarY = self.y - 16
    
    lg.setColor(COLORS.RED)
    lg.rectangle("fill", healthBarX, healthBarY, SPRITE_SIZE, healthBarHeight)
    lg.setColor(COLORS.GREEN)
    lg.rectangle("fill", healthBarX, healthBarY, healthBarWidth, healthBarHeight)
    --]]

    -- Draw health text
    lg.setColor(COLORS.WHITE)
    lg.setFont(self.ctx.fonts.fontM)
    lg.printf(math.ceil(self.player.health), self.x, healthBarY - 4, SPRITE_SIZE, "center")

    -- Draw shield bar
    if self.player.shield > 0 then
        local shieldBarY = healthBarY - healthBarHeight
        lg.setColor(COLORS.BLUE)
        lg.rectangle("fill", healthBarX, shieldBarY, SPRITE_SIZE, healthBarHeight)
        lg.setColor(COLORS.WHITE)
        lg.printf(self.player.shield, healthBarX, shieldBarY - 4, SPRITE_SIZE, "center")
    end
end

function BasePlayerRenderer:drawEffectsList()
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

function BasePlayerRenderer:drawStackEffectsHelper()
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

function BasePlayerRenderer:drawDurationEffectsHelper()
    local durationEffects = {}
    for _, effect in ipairs(self.player.durationEffects) do
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

function BasePlayerRenderer:drawSelectedCard()
    error("BasePlayerRenderer:drawSelectedCard() must be implemented by subclass")
end

function BasePlayerRenderer:update(dt)
    self:updateDamageDisplay(dt)
    self:updateCharAnimations(dt)
    self:updateSelectedCard(dt)
end

function BasePlayerRenderer:updateDamageDisplay(dt)
    if #self.damageDisplays == 0 then
        return
    end
    
    for i = #self.damageDisplays, 1, -1 do
        local display = self.damageDisplays[i]
        display.timeLeft = display.timeLeft - dt
        if display.timeLeft <= 0 then
            table.remove(self.damageDisplays, i)
        end
    end
end

function BasePlayerRenderer:updateCharAnimations(dt)
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

function BasePlayerRenderer:updateSelectedCard(dt)
    error("BasePlayerRenderer:updateSelectedCard(dt) must be implemented by subclass")
end