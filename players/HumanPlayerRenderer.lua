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
    local w = MINI_CARD_WIDTH

    local function drawLibrarySlot(lineSmallTop, lineLarge, lineSmallBottom, bgColor, fgColor)
        lg.setColor(bgColor)
        lg.rectangle("fill", x, y, w, MINI_CARD_HEIGHT)
        lg.setFont(fonts.fontS)
        lg.setColor(fgColor)
        lg.printf(lineSmallTop, x, y + 4, w, "center")
        lg.setFont(fonts.fontL)
        -- Colored-text tables are multiplied by the current color; use white so segment colors show.
        if type(lineLarge) == "table" then
            lg.setColor(COLORS.WHITE)
        else
            lg.setColor(fgColor)
        end
        lg.printf(lineLarge, x, y + 8, w, "center")
        lg.setFont(fonts.fontS)
        lg.setColor(fgColor)
        lg.printf(lineSmallBottom, x, y + 44, w, "center")
    end

    for i, card in ipairs(self.player.library) do
        if card.x ~= self.libraryX or card.y ~= self.libraryY then
            card:drawMini()
        end
    end

    local cantDraw = "so you can't draw"
    if incanting then
        drawLibrarySlot("you are", "casting", cantDraw, COLORS.GREY, COLORS.WHITE)
    elseif #self.player.library == 0 then
        drawLibrarySlot("your library is", "empty", cantDraw, COLORS.GREY, COLORS.WHITE)
    elseif #self.player.hand >= MAX_HAND_SIZE then
        drawLibrarySlot("your hand is", "full", cantDraw, COLORS.GREY, COLORS.WHITE)
    elseif drawWord ~= nil then
        local coloredDrawWord = Text.colorizeText(drawWord, self.ctx.ui.input, COLORS.WHITE, COLORS.GREEN, COLORS.WHITE)
        drawLibrarySlot("type", coloredDrawWord, "to draw", COLORS.BLACK, COLORS.WHITE)
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