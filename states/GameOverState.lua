require "states.BaseState"

-- Game Over State
GameOverState = {}
setmetatable(GameOverState, {__index = BaseState})
GameOverState.__index = GameOverState

function GameOverState:new()
    local state = setmetatable(BaseState:new(), self)
    state.gameOverMessage = ""
    return state
end

function GameOverState:enter()
    if player1.health <= 0 and player2.health <= 0 then
        self.gameOverMessage = "Tie"
    elseif player1.health <= 0 then
        self.gameOverMessage = "Player2 Wins"
    elseif player2.health <= 0 then
        self.gameOverMessage = "Player1 Wins"
    end
end

function GameOverState:draw()
    lg.setFont(fontXL)
    lg.printf(self.gameOverMessage, 0, 200, 800, "center")
    lg.setFont(fontM)
    lg.printf("[R]estart Game\n[Q]uit", 0, 300, 800, "center")
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

