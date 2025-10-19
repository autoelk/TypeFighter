require "scenes.BaseScene"

-- Card Browse Scene
CardBrowseScene = {}
setmetatable(CardBrowseScene, {
    __index = BaseScene
})
CardBrowseScene.__index = CardBrowseScene

function CardBrowseScene:new()
    local scene = setmetatable(BaseScene:new(), self)
    scene.name = "cardBrowse"
    scene.posy = 10 -- Scroll position
    scene.cardsPerRow = 4
    scene.cards = {}
    scene.controlsHint = "[q] to go back"
    for _, cardName in ipairs(cardManager:getAllCardNames()) do
        table.insert(scene.cards, cardManager:createCard(cardName))
    end
    return scene
end

function CardBrowseScene:enter()
    messageRight = self.controlsHint
end

function CardBrowseScene:update(dt)
    -- Update card positions for browsing layout
    local margin = 15
    local colSpacing = LARGE_CARD_WIDTH + margin
    local rowSpacing = LARGE_CARD_HEIGHT + margin
    local displayWidth = self.cardsPerRow * colSpacing + margin
    local startX = (GAME_WIDTH - displayWidth) / 2 + margin
    for i = 1, #self.cards do
        local idx = i - 1
        local colNum, rowNum = idx % self.cardsPerRow, math.floor(idx / self.cardsPerRow)
        local x = startX + colSpacing * colNum
        local y = rowSpacing * rowNum + self.posy
        self.cards[i]:move(x, y)
        self.cards[i]:update(dt)
    end
end

function CardBrowseScene:draw()
    for i = 1, #self.cards do
        self.cards[i]:draw()
    end
end

function CardBrowseScene:keypressed(key)
    if key == "return" then
        if self:processInput() == "q" then
            self.sceneManager:changeScene("menu")
        end
        input = ""
    end
    BaseScene.keypressed(self, key)
end

function CardBrowseScene:wheelmoved(x, y)
    self.posy = self.posy + y * SCROLL_SPEED

    -- Scrolling boundaries
    local margin = 15
    if self.posy > margin then
        self.posy = margin
    elseif self.posy <= (math.ceil(#self.cards / self.cardsPerRow) - 1) * -(LARGE_CARD_HEIGHT + margin) then
        self.posy = (math.ceil(#self.cards / self.cardsPerRow) - 1) * -(LARGE_CARD_HEIGHT + margin)
    end
end
