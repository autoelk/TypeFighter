require "states.BaseState"

-- Card Selection State
CardSelectState = {}
setmetatable(CardSelectState, {__index = BaseState})
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
    end
    -- Reset player picks for card selection
    player1.picks = 5
    player2.picks = 5
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
    player2PickSpeed = player1.picks + 1
    player2PickCooldown = player2PickCooldown - dt
    if player2PickCooldown <= 0 then
        local cardToPick = math.random(1, #cards)
        if cards[cardToPick].deck == 0 and cards[cardToPick].name ~= "ritual" and player2.picks > 0 then
            cards[cardToPick].deck = 2
            player2.picks = player2.picks - 1
            player2PickCooldown = player2PickCooldown + player2PickSpeed
        end
    end
    player2PickCooldown = math.max(player2PickCooldown, 0)
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
        local location = findCard(userInput)
        
        if location > 0 then
            self:handleCardSelection(location)
        elseif userInput == "start" or userInput == "p" then
            self:handleGameStart()
        elseif userInput == "q" or userInput == "quit" then
            self.stateManager:changeState("menu")
        else
            message = "Type card names to choose them"
        end
        input = ""
    end
end

function CardSelectState:handleCardSelection(location)
    if cards[location].deck == 1 then
        cards[location].deck = 0
        message = "removed " .. cards[location].name
        player1.picks = player1.picks + 1
    elseif cards[location].deck == 2 then
        message = cards[location].name .. " is in player2's deck"
    elseif player1.picks <= 0 then
        message = "no picks remaining"
    else
        cards[location].deck = 1
        message = "added " .. cards[location].name
        player1.picks = player1.picks - 1
    end
end

function CardSelectState:handleGameStart()
    if player1.picks > 0 then
        message = "you have " .. player1.picks .. " picks left"
    elseif player2.picks > 0 then
        message = "player2 has " .. player2.picks .. " picks left"
    else
        message = "Game Started"
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