require "states.BaseState"

-- Card Selection State
CardSelectState = {}
setmetatable(CardSelectState, {
    __index = BaseState
})
CardSelectState.__index = CardSelectState

function CardSelectState:new()
    local state = setmetatable(BaseState:new(), self)
    state.posy = 10 -- scroll position
    state.cardsPerRow = 4
    return state
end

function CardSelectState:enter()
    gameManager.currentState = "CardSelectState"
    message2 = "[P]lay [Q] to go back"
    -- Reset decks
    for i = 1, #cards do
        cards[i].deck = 0
        cards[i]:loop()
    end
    -- Reset player picks for card selection
    local humanPlayer = gameManager:getHumanPlayer()
    local aiPlayer = gameManager:getAIPlayer()
    humanPlayer.picks = MAX_DECK_SIZE
    humanPlayer.deck = {}
    aiPlayer.picks = MAX_DECK_SIZE
    aiPlayer.deck = {}
    aiPlayer.pickCooldown = aiPlayer.pickSpeed
end

function CardSelectState:update(dt)
    local human = gameManager:getHumanPlayer()
    local ai = gameManager:getAIPlayer()

    local margin = 10

    -- draw ai selected cards
    for i = 1, #ai.deck do
        cards[ai.deck[i]]:move(GAME_WIDTH - LARGE_CARD_WIDTH - margin, 25 * (i - 1) + margin + 40)
    end

    -- draw human selected cards
    for i = 1, #human.deck do
        cards[human.deck[i]]:move(margin, 25 * (i - 1) + margin + 40)
    end

    -- draw remaining cards
    local remCardIdx = 0
    local colSpacing = LARGE_CARD_WIDTH + margin
    local rowSpacing = LARGE_CARD_HEIGHT + margin
    local displayWidth = self.cardsPerRow * colSpacing + margin
    local startX = (GAME_WIDTH - displayWidth) / 2 + margin
    for i = 1, #cards do
        if cards[i].deck == 0 then
            local colNum, rowNum = remCardIdx % self.cardsPerRow, math.floor(remCardIdx / self.cardsPerRow)
            local x = startX + colSpacing * colNum
            local y = rowSpacing * rowNum + self.posy
            cards[i]:move(x, y)
            remCardIdx = remCardIdx + 1
        end
    end
end

function CardSelectState:draw()
    local human = gameManager:getHumanPlayer()
    local ai = gameManager:getAIPlayer()
    local margin = 10

    lg.setFont(fontM)
    lg.setColor(COLORS.WHITE)
    lg.printf("your deck " .. #human.deck .. "/" .. MAX_DECK_SIZE, margin, margin, LARGE_CARD_WIDTH, "center")
    lg.printf("opp deck " .. #ai.deck .. "/" .. MAX_DECK_SIZE, GAME_WIDTH - LARGE_CARD_WIDTH - margin, margin,
        LARGE_CARD_WIDTH, "center")

    for i = 1, #cards do
        if cards[i].deck == 0 then
            cards[i]:display()
        end
    end

    for i = 1, #human.deck do
        cards[human.deck[i]]:display()
    end

    for i = 1, #ai.deck do
        cards[ai.deck[i]]:display()
    end

    -- When both players have full decks, prompt player to start
    if #human.deck == MAX_DECK_SIZE and #ai.deck == MAX_DECK_SIZE then
        lg.setFont(fontL)
        lg.setColor(COLORS.BLACK)
        lg.rectangle("fill", 0, 300, GAME_WIDTH, 50)
        lg.setColor(COLORS.WHITE)
        lg.printf("both decks full, type [p] to start", 0, 300, GAME_WIDTH, "center")
    end
end

function CardSelectState:keypressed(key)
    if key == "return" then
        local userInput = self:processInput()
        local idx = cardFactory:findCard(userInput)

        if idx > 0 then
            self:handleCardSelection(idx)
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

function CardSelectState:handleCardSelection(idx)
    local human = gameManager:getHumanPlayer()
    if not human then
        return
    end

    if cards[idx].deck == human.id then
        human:removeCard(idx)
        message = "removed " .. cards[idx].name
    elseif cards[idx].deck ~= 0 then
        message = cards[idx].name .. " is in other player's deck"
    elseif human.picks <= 0 then
        message = "no picks remaining"
    else
        human:addCard(idx)
        message = "added " .. cards[idx].name
    end
end

function CardSelectState:handleGameStart()
    local human = gameManager:getHumanPlayer()
    local ai = gameManager:getAIPlayer()

    if human and human.picks > 0 then
        message = "you have " .. human.picks .. " picks left"
    elseif ai and ai.picks > 0 then
        message = "player2 has " .. ai.picks .. " picks left"
    else
        message = "game started"
        self.stateManager:changeState("game")
    end
end

function CardSelectState:wheelmoved(x, y)
    self.posy = self.posy + y * SCROLL_SPEED

    -- Calculate bounds based on grid height
    local remaining = 0
    for i = 1, #cards do
        if cards[i].deck == 0 then
            remaining = remaining + 1
        end
    end

    local margin = 10
    local rows = math.ceil(math.max(remaining, 1) / self.cardsPerRow)
    local gridHeight = rows * (LARGE_CARD_HEIGHT + margin)

    local headerHeight = 40
    local visibleHeight = GAME_HEIGHT - headerHeight - 80

    local topLimit = margin
    local minPosy = math.min(topLimit, visibleHeight - gridHeight)

    if self.posy > topLimit then self.posy = topLimit end
    if self.posy < minPosy then self.posy = minPosy end
end
