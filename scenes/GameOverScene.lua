require "scenes.BaseScene"

-- Game Over Scene
GameOverScene = {}
setmetatable(GameOverScene, {
    __index = BaseScene
})
GameOverScene.__index = GameOverScene

function GameOverScene:new()
    local scene = setmetatable(BaseScene:new(), self)
    scene.name = "gameOver"
    scene.gameOverMessage = ""
    scene.controlsHint = "[r]estart [q]uit"
    return scene
end

function GameOverScene:enter()
    messageRight = self.controlsHint
    -- Decide game over message
    local player1Controller = sceneManager:getScene("game").player1Controller
    local player2Controller = sceneManager:getScene("game").player2Controller
    if not player1Controller.player.isAlive and not player2Controller.player.isAlive then
        self.gameOverMessage = "tie"
    elseif not player1Controller.player.isAlive then
        self.gameOverMessage = "player 2 wins"
    elseif not player2Controller.player.isAlive then
        self.gameOverMessage = "player 1 wins"
    else
        -- This should never happen
        self.gameOverMessage = "game over"
    end
end

function GameOverScene:draw()
    -- Dim the background
    lg.setColor(0, 0, 0, 0.5)
    lg.rectangle("fill", 0, 0, GAME_WIDTH, GAME_HEIGHT)

    -- Draw game over text on top
    lg.setColor(COLORS.WHITE)
    lg.setFont(fontXL)
    lg.printf(self.gameOverMessage, 0, 200, GAME_WIDTH, "center")
    lg.setFont(fontM)
    lg.printf("[r]estart\n[q]uit", 0, 300, GAME_WIDTH, "center")
end

function GameOverScene:handleInput(userInput)
    -- TODO: Decide what restart should do with new game structure
    if userInput == "q" or userInput == "quit" then
        love.event.quit()
    elseif userInput == "r" or userInput == "restart" then
        self.sceneManager:changeScene("menu")
    end
end
