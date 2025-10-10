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
    gameManager.currentState = "GameOverState"
    message2 = "[r]estart [q]uit"
    local player1 = gameManager:getPlayer(1)
    local player2 = gameManager:getPlayer(2)
    -- Decide game over message based on isAlive flags
    if not player1.isAlive and not player2.isAlive then
        self.gameOverMessage = "tie"
    elseif not player1.isAlive then
        self.gameOverMessage = "player 2 wins"
    elseif not player2.isAlive then
        self.gameOverMessage = "player 1 wins"
    end
end

function GameOverState:draw()
    lg.setFont(fontXL)
    lg.printf(self.gameOverMessage, 0, 200, GAME_WIDTH, "center")
    lg.setFont(fontM)
    lg.printf("[r]estart game\n[q]uit", 0, 300, GAME_WIDTH, "center")

    for i = 1, #cards do
        if cards[i].t > 0 then
            local card = cards[i]
            local animX = card.x
            local animSx = card.scale
            local animSy = card.scale

            if card.deck == 2 then
                animSx = animSx * -1
                animX = animX + SCALED_SPRITE_SIZE
            end

            card:animate(animX, card.y, card.rotation, animSx, animSy, card.offsetX, card.offsetY)
        end
    end
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
