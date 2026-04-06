local Text = require "util.Text"

-- View class for a human player
HumanPlayerRenderer = {}
setmetatable(HumanPlayerRenderer, {
    __index = BasePlayerRenderer
})
HumanPlayerRenderer.__index = HumanPlayerRenderer

function HumanPlayerRenderer:new(ctx, player)
    local renderer = BasePlayerRenderer:new(ctx, player)
    renderer.x = 256
    renderer.mirror = false
    renderer.libraryX = (GAME_WIDTH - MINI_CARD_WIDTH) / 2
    renderer.libraryY = 100
    renderer.handX = (GAME_WIDTH - (MAX_HAND_SIZE * (MINI_CARD_WIDTH + 8) - 8)) / 2
    renderer.handY = 544
    return setmetatable(renderer, self)
end

function HumanPlayerRenderer:draw(drawWord, incanting)
    BasePlayerRenderer.draw(self)
    self:drawHand()
    self:drawLibrary(drawWord, incanting)
end

-- Draw cards in hand as mini cards
function HumanPlayerRenderer:drawHand()
    for i, card in ipairs(self.player.hand) do
        card:drawMini()
    end
end

function HumanPlayerRenderer:drawSelectedCard()
    if self.player.selectedCard then
        self.player.selectedCard:drawMini()
    end
end

-- Draw library with draw word or card back
function HumanPlayerRenderer:drawLibrary(drawWord, incanting)
    local fonts = self.ctx.fonts
    local x, y = self.libraryX, self.libraryY

    for i, card in ipairs(self.player.library) do
        if card.x ~= self.libraryX or card.y ~= self.libraryY then
            card:drawMini()
        end
    end

    -- TODO: Consider if this makes deck size too confusing for the player
    if incanting then
        -- lg.setFont(fonts.fontS)
        -- lg.setColor(COLORS.WHITE)
        -- lg.printf("incanting", x, y + 24, MINI_CARD_WIDTH, "center")
    elseif #self.player.library == 0 then
        -- lg.setFont(fonts.fontS)
        -- lg.setColor(COLORS.WHITE)
        -- lg.printf("library empty", x, y + 24, MINI_CARD_WIDTH, "center")
    elseif #self.player.hand >= MAX_HAND_SIZE then
        -- lg.setFont(fonts.fontS)
        -- lg.setColor(COLORS.WHITE)
        -- lg.printf("hand full", x, y + 24, MINI_CARD_WIDTH, "center")
    elseif drawWord ~= nil then
        lg.setColor(COLORS.BLACK)
        lg.rectangle("fill", x, y, MINI_CARD_WIDTH, MINI_CARD_HEIGHT)
        lg.setFont(fonts.fontS)
        lg.setColor(COLORS.WHITE)
        local coloredDrawWord = Text.colorizeText(drawWord, self.ctx.ui.input, COLORS.WHITE, COLORS.GREEN, COLORS.WHITE)
        lg.printf("type", x, y + 4, MINI_CARD_WIDTH, "center")
        lg.printf("to draw", x, y + 44, MINI_CARD_WIDTH, "center")
        lg.setFont(fonts.fontL)
        lg.printf(coloredDrawWord, x, y + 8, MINI_CARD_WIDTH, "center")
    end
end

function HumanPlayerRenderer:drawDeck()
    for i, card in ipairs(self.player.deck) do
        card:drawMini()
    end
end

function HumanPlayerRenderer:update(dt)
    BasePlayerRenderer.update(self, dt)
    self:updateHand(dt)
    self:updateLibrary(dt)
    self:updateSelectedCard(dt)
end

-- Update positions of cards in hand
function HumanPlayerRenderer:updateHand(dt)
    local margin = 8
    for i, card in ipairs(self.player.hand) do
        local destX = self.handX + (MINI_CARD_WIDTH + margin) * (i - 1)
        card:move(destX, self.handY)
    end
end

function HumanPlayerRenderer:updateLibrary(dt)
    for i, card in ipairs(self.player.library) do
        card:move(self.libraryX, self.libraryY)
    end
end

-- Update positions of cards in deck, only used in CardSelectScene
function HumanPlayerRenderer:updateDeck(dt)
    local margin = 8
    local deckX = self.handX
    for i, card in ipairs(self.player.deck) do
        card:move(deckX, (MINI_CARD_HEIGHT + margin) * i + 100)
    end
end

function HumanPlayerRenderer:updateSelectedCard(dt)
    if self.player.selectedCard then
        self.player.selectedCard:move((GAME_WIDTH - MINI_CARD_WIDTH) / 2, 300)
    end
end