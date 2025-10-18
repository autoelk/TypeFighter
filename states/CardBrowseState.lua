require "states.BaseState"

-- Card Browse State
CardBrowseState = {}
setmetatable(CardBrowseState, {
    __index = BaseState
})
CardBrowseState.__index = CardBrowseState

function CardBrowseState:new()
    local state = setmetatable(BaseState:new(), self)
    state.posy = 10 -- Scroll position
    state.cardsPerRow = 4
    state.cards = {}
    for _, cardName in ipairs(cardManager:getAllCardNames()) do
        table.insert(state.cards, cardManager:createCard(cardName))
    end
    return state
end

function CardBrowseState:enter()
    message2 = "[Q] to go back"
end

function CardBrowseState:update(dt)
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

function CardBrowseState:draw()
    for i = 1, #self.cards do
        self.cards[i]:draw()
    end
end

function CardBrowseState:keypressed(key)
    if key == "return" then
        if self:processInput() == "q" then
            self.sceneManager:changeState("menu")
        end
        input = ""
    end
    BaseState.keypressed(self, key)
end

function CardBrowseState:wheelmoved(x, y)
    self.posy = self.posy + y * SCROLL_SPEED

    -- Scrolling boundaries
    local margin = 15
    if self.posy > margin then
        self.posy = margin
    elseif self.posy <= (math.ceil(#self.cards / self.cardsPerRow) - 1) * -(LARGE_CARD_HEIGHT + margin) then
        self.posy = (math.ceil(#self.cards / self.cardsPerRow) - 1) * -(LARGE_CARD_HEIGHT + margin)
    end
end
