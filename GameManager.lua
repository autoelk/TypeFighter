GameManager = {}
GameManager.__index = GameManager

function GameManager:new()
    local manager = {
        players = {},
        humanPlayer = nil,
        aiPlayer = nil
    }
    setmetatable(manager, self)
    return manager
end

function GameManager:addPlayer(player)
    self.players[player.num] = player
    
    if player.__index and player.__index.handleInput then
        self.humanPlayer = player
    else
        self.aiPlayer = player
    end
end

function GameManager:getPlayer(playerNumber)
    return self.players[playerNumber]
end

function GameManager:getHumanPlayer()
    return self.humanPlayer
end

function GameManager:getAIPlayer()
    return self.aiPlayer
end

function GameManager:getOpponent(player)
    return self.players[3 - player.num]
end

function GameManager:getAllPlayers()
    return self.players
end

function GameManager:reset()
    self.players = {}
    self.humanPlayer = nil
    self.aiPlayer = nil
end

-- Global instance
gameManager = GameManager:new()