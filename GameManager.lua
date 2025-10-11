GameManager = {}
GameManager.__index = GameManager

function GameManager:new()
    local manager = {
        humanPlayer = nil,
        aiPlayer = nil,
        cards = {},
        currentState = nil
    }
    setmetatable(manager, self)
    return manager
end

function GameManager:addPlayer(player)
    if player.__index and player.__index.handleInput then
        self.humanPlayer = player
    else
        self.aiPlayer = player
    end
end

function GameManager:getHumanPlayer()
    if not self.humanPlayer then
        error("No human player found!")
    end
    return self.humanPlayer
end

function GameManager:getAIPlayer()
    if not self.aiPlayer then
        error("No AI player found!")
    end
    return self.aiPlayer
end

function GameManager:reset()
    self.humanPlayer = nil
    self.aiPlayer = nil
    self.cards = {}
    self.currentState = nil
end

function GameManager:getCards()
    return self.cards
end

function GameManager:setCard(index, card)
    self.cards[index] = card
end

function GameManager:getCurrentStateName()
    if self.currentState then
        return self.currentState
    end
end

-- Global instance
gameManager = GameManager:new()
