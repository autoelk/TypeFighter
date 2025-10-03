require "states.BaseState"

-- Card Selection State
CardSelectState = {}
setmetatable(CardSelectState, {
    __index = BaseState
})
CardSelectState.__index = CardSelectState

function CardSelectState:new()
    local state = setmetatable(BaseState:new(), self)
    state.posy = 10
    return state
end

function CardSelectState:enter()
    message2 = "[P]lay [Q] to go back"
    -- Reset decks
    for i = 1, #cards do
        cards[i].deck = 0
        cards[i]:Loop()
    end
    -- Reset player picks for card selection
    local humanPlayer = gameManager:getHumanPlayer()
    local aiPlayer = gameManager:getAIPlayer()
    if humanPlayer then
        humanPlayer.picks = 5
    end
    if aiPlayer then
        aiPlayer.picks = 5
    end
end

function CardSelectState:update(dt)
    -- Update deck array
    for k, v in pairs(deck) do
        deck[k] = nil
    end
    local cardsGone = 0
    for i = 1, #cards do
        if cards[i].deck == 1 then
            cardsGone = cardsGone + 1
            table.insert(deck, i)
            cards[i]:Move(595, 25 * #deck)
        else
            local colNum, rowNum = (i - cardsGone) % 3, math.ceil((i - cardsGone) / 3)
            if colNum == 0 then
                colNum = 3
            end
            cards[i]:Move(190 * (colNum - 1) + 10, 262 * (rowNum - 1) + self.posy)
        end
    end

    -- Player2 AI picking
    local humanPlayer = gameManager:getHumanPlayer()
    local aiPlayer = gameManager:getAIPlayer()
    if aiPlayer and humanPlayer then
        aiPlayer:updateCardSelection(dt, humanPlayer.picks)
    end
end

function CardSelectState:draw()
    for i = 1, #cards do
        if cards[i].deck ~= 1 then
            cards[i]:Display()
        end
    end
    -- Draw cards in deck on top
    for i = 1, #cards do
        if cards[i].deck == 1 then
            cards[i]:Display()
        end
    end
end

function CardSelectState:keypressed(key)
    if key == "return" then
        local userInput = self:processInput()
        local location = cardFactory:findCard(userInput)

        if location > 0 then
            self:handleCardSelection(location)
        elseif userInput == "start" or userInput == "p" then
            self:handleGameStart()
        elseif userInput == "q" or userInput == "quit" then
            self.stateManager:changeState("menu")
        else
            message = "type card names to choose them"
        end
        input = ""
    end
end

function CardSelectState:handleCardSelection(location)
    local humanPlayer = gameManager:getHumanPlayer()
    if not humanPlayer then
        return
    end

    if cards[location].deck == 1 then
        cards[location].deck = 0
        message = "removed " .. cards[location].name
        humanPlayer.picks = humanPlayer.picks + 1
    elseif cards[location].deck == 2 then
        message = cards[location].name .. " is in player2's deck"
    elseif humanPlayer.picks <= 0 then
        message = "no picks remaining"
    else
        cards[location].deck = 1
        message = "added " .. cards[location].name
        humanPlayer.picks = humanPlayer.picks - 1
    end
end

function CardSelectState:handleGameStart()
    local humanPlayer = gameManager:getHumanPlayer()
    local aiPlayer = gameManager:getAIPlayer()

    if humanPlayer and humanPlayer.picks > 0 then
        message = "you have " .. humanPlayer.picks .. " picks left"
    elseif aiPlayer and aiPlayer.picks > 0 then
        message = "player2 has " .. aiPlayer.picks .. " picks left"
    else
        message = "game started"
        self.stateManager:changeState("game")
    end
end

function CardSelectState:wheelmoved(x, y)
    self.posy = self.posy + y * 75
    -- Scrolling boundaries
    if self.posy >= 200 then
        self.posy = 200
    elseif self.posy <= (math.ceil(#cards / 3) - 1) * -317 + 25 then
        self.posy = (math.ceil(#cards / 3) - 1) * -317 + 25
    end
end
