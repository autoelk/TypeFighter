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
    return state
end

function CardBrowseState:enter()
    message2 = "[Q] to go back"
    for i = 1, #cards do
        cards[i]:Loop()
    end
end

function CardBrowseState:update(dt)
    -- Update card positions for browsing layout
    for i = 1, #cards do
        local colNum, rowNum = i % 4, math.ceil(i / 4)
        if colNum == 0 then
            colNum = 4
        end
        cards[i]:Move(196 * (colNum - 1) + 16, 268 * (rowNum - 1) + self.posy)
    end
end

function CardBrowseState:draw()
    for i = 1, #cards do
        cards[i]:Display()
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
    self.posy = self.posy + y * 75
    -- Scrolling boundaries
    if self.posy >= 200 then
        self.posy = 200
    elseif self.posy <= (math.ceil(#cards / 3) - 1) * -317 + 25 then
        self.posy = (math.ceil(#cards / 3) - 1) * -317 + 25
    end
end
