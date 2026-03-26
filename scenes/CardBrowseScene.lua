require "scenes.BaseScene"
local SceneId = require "enums.SceneId"

-- Card Browse Scene
CardBrowseScene = {}
setmetatable(CardBrowseScene, {
    __index = BaseScene
})
CardBrowseScene.__index = CardBrowseScene

function CardBrowseScene:new(ctx)
    local scene = setmetatable(BaseScene:new(ctx), self)
    scene.name = SceneId.CardBrowse
    scene.posy = 16 -- Scroll position
    scene.cardsPerRow = 4
    scene.cards = {}
    scene.controlsHint = "[quit]"
    scene.availableCommands = { "quit" }
    for _, cardName in ipairs(ctx.cardManager:getAllCardNames()) do
        table.insert(scene.cards, ctx.cardManager:createCard(cardName))
    end
    return scene
end

function CardBrowseScene:enter()
    self.ctx.ui.messageLeft = ""
    self.ctx.ui.messageRight = self.controlsHint
end

function CardBrowseScene:update(dt)
    -- Update card positions for browsing layout
    local margin = 16
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

function CardBrowseScene:handleInput(userInput)
    if userInput == "quit" then
        self.ctx.sceneManager:changeScene(SceneId.Menu)
    end
end

function CardBrowseScene:wheelmoved(x, y)
    self.posy = self.posy + y * SCROLL_SPEED

    -- Scrolling boundaries
    local margin = 16
    local numRows = math.ceil(#self.cards / self.cardsPerRow)
    local numRowsOnScreen = math.floor(GAME_HEIGHT / (LARGE_CARD_HEIGHT + margin))
    local minScroll = (numRows - numRowsOnScreen) * -(LARGE_CARD_HEIGHT + margin) - 32
    self.posy = math.max(minScroll, math.min(margin, self.posy))
end
