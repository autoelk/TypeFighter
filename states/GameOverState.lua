require "states.BaseState"

-- Game Over State
GameOverState = {}
setmetatable(GameOverState, {
    __index = BaseState
})
GameOverState.__index = GameOverState

function GameOverState:new()
    local state = setmetatable(BaseState:new(), self)
    state.gameOverMessage = ""
    return state
end

function GameOverState:enter()
    local player1 = gameManager:getPlayer(1)
    local player2 = gameManager:getPlayer(2)
    if player1.health <= 0 and player2.health <= 0 then
        self.gameOverMessage = "tie"
    elseif player1.health <= 0 then
        self.gameOverMessage = "player 2 wins"
    elseif player2.health <= 0 then
        self.gameOverMessage = "player 1 wins"
    end
end

function GameOverState:draw()
    lg.setFont(fontXL)
    lg.printf(self.gameOverMessage, 0, 200, 800, "center")
    lg.setFont(fontM)
    lg.printf("[r]estart game\n[q]uit", 0, 300, 800, "center")
end

function GameOverState:keypressed(key)
    if key == "return" then
        local userInput = self:processInput()
        if userInput == "q" or userInput == "quit" then
            love.event.quit()
        elseif userInput == "r" or userInput == "restart" then
            self.stateManager:changeState("menu")
        end
        input = ""
    end
end

