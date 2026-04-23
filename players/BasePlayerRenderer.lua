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
        mirrorCharSprite = false, -- Whether to mirror the character sprite

        idleAnim = ctx.resourceManager:newAnimation(player.character.idleSprite, "loop"),
        castAnim = ctx.resourceManager:newAnimation(player.character.castSprite, "once"),
        deathAnim = ctx.resourceManager:newAnimation(player.character.deathSprite, "once"),
        isCasting = false,
        castAnimFinished = false,

        damageDisplays = {}
    }
    return setmetatable(renderer, self)
end

function BasePlayerRenderer:reset()
    self.isCasting = false

    self.deathAnim:reset()
    self.castAnim:reset()
    self.idleAnim:reset()

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
    self.castAnim:reset()
end

function BasePlayerRenderer:draw()
    self:drawChar()
    self:drawHealthBar()
    if self.player.isAlive then
        self:drawSelectedCard()
        self:drawEffectsList()
    end
    self:drawDamageDisplay()
end

function BasePlayerRenderer:drawChar()
    lg.setColor(COLORS.WHITE)
    local scaleX = PIXEL_TO_GAME_SCALE
    local x = self.x
    if self.mirror and self.mirrorCharSprite then
        scaleX = -PIXEL_TO_GAME_SCALE
        x = self.x + SPRITE_SIZE
    end

    if not self.player.isAlive then
        self.deathAnim:draw(x, self.y, 0, scaleX, PIXEL_TO_GAME_SCALE)
    elseif self.isCasting then
        self.castAnim:draw(x, self.y, 0, scaleX, PIXEL_TO_GAME_SCALE)
    else
        self.idleAnim:draw(x, self.y, 0, scaleX, PIXEL_TO_GAME_SCALE)
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
    local healthBarY = self.y - 24
    
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
    local effects = {}
    for _, effect in pairs(self.player.effects) do
        local eff = {
            name = effect.name,
            stacks = effect.stacks,
        }
        table.insert(effects, eff)
    end

    -- sort effects alphabetically by name
    table.sort(effects, function(a, b)
        return a.name < b.name
    end)

    local textAlign = "left"
    local baseX = self.x
    local baseY = self.y + SPRITE_SIZE + 8

    lg.setFont(self.ctx.fonts.fontS)
    for i, effect in ipairs(effects) do
        lg.setColor(COLORS.WHITE)
        lg.printf(
            effect.name .. " x" .. math.floor(effect.stacks),
            baseX,
            baseY + (i - 1) * 16,
            SPRITE_SIZE,
            textAlign
        )
    end
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
        self.deathAnim:update(dt)
    elseif self.isCasting then
        if self.castAnim:update(dt) then
            self.isCasting = false
        end
    else
        self.idleAnim:update(dt)
    end
end

function BasePlayerRenderer:updateSelectedCard(dt)
    error("BasePlayerRenderer:updateSelectedCard(dt) must be implemented by subclass")
end