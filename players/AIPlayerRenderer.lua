-- View class for an AI player
AIPlayerRenderer = {}
setmetatable(AIPlayerRenderer, {
    __index = BasePlayerRenderer
})
AIPlayerRenderer.__index = AIPlayerRenderer

function AIPlayerRenderer:new(ctx, player)
    local renderer = BasePlayerRenderer:new(ctx, player)
    renderer.x = GAME_WIDTH - 256 - SPRITE_SIZE
    renderer.mirror = true
    renderer.tint = COLORS.RED
    return setmetatable(renderer, self)
end

function AIPlayerRenderer:draw()
    BasePlayerRenderer.draw(self)
end

function AIPlayerRenderer:drawSelectedCard()
    if self.player.selectedCard then
        self.player.selectedCard:drawMini()
    end
end

function AIPlayerRenderer:update(dt)
    BasePlayerRenderer.update(self, dt)
    self:updateSelectedCard(dt)
end

function AIPlayerRenderer:updateSelectedCard(dt)
    if self.player.selectedCard then
        self.player.selectedCard:move(self.x, self.y - SPRITE_SIZE)
    end
end
