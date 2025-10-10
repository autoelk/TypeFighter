require "states.BaseState"

-- Card Browse State
CardBrowseState = {}
setmetatable(CardBrowseState, {
    __index = BaseState
})
CardBrowseState.__index = CardBrowseState

function CardBrowseState:new()
    local state = setmetatable(BaseState:new(), self)
    state.posy = 10 -- Card scroll position
    state.cardsPerRow = 4
    return state
end

function CardBrowseState:enter()
    gameManager.currentState = "CardBrowseState"
    message2 = "[Q] to go back"
    for i = 1, #cards do
        cards[i]:loop()
    end
end

function CardBrowseState:update(dt)
    -- Update card positions for browsing layout
    local margin = 15
    local colSpacing = LARGE_CARD_WIDTH + margin
    local rowSpacing = LARGE_CARD_HEIGHT + margin
    for i = 1, #cards do
        local idx = i - 1
        local colNum, rowNum = idx % self.cardsPerRow, math.floor(idx / self.cardsPerRow)
        local x = margin + colSpacing * colNum
        local y = rowSpacing * rowNum + self.posy
        cards[i]:move(x, y)
    end
end

function CardBrowseState:draw()
    for i = 1, #cards do
        cards[i]:display()
    end
end

function CardBrowseState:keypressed(key)
    if key == "return" then
        if self:processInput() == "q" then
            self.stateManager:changeState("menu")
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
    elseif self.posy <= (math.ceil(#cards / 4) - 1) * -(LARGE_CARD_HEIGHT + margin) then
        self.posy = (math.ceil(#cards / 4) - 1) * -(LARGE_CARD_HEIGHT + margin)
    end
end
