require "scenes.BaseScene"

-- Game Over Scene
GameOverScene = {}
setmetatable(GameOverScene, {
    __index = BaseScene
})
GameOverScene.__index = GameOverScene

function GameOverScene:new()
    local scene = setmetatable(BaseScene:new(), self)
    scene.gameOverMessage = ""
    return scene
end

function GameOverScene:enter()
    message2 = "[r]estart [q]uit"
    local humanPlayer = HUMANPLAYER
    local aiPlayer = AIPLAYER
    -- Decide game over message based on isAlive flags
    if not humanPlayer.isAlive and not aiPlayer.isAlive then
        self.gameOverMessage = "tie"
    elseif not humanPlayer.isAlive then
        self.gameOverMessage = "player 2 wins"
    elseif not aiPlayer.isAlive then
        self.gameOverMessage = "player 1 wins"
    end
end

function GameOverScene:update(dt)
end

function GameOverScene:draw()
    lg.setFont(fontXL)
    lg.printf(self.gameOverMessage, 0, 200, GAME_WIDTH, "center")
    lg.setFont(fontM)
    lg.printf("[r]estart game\n[q]uit", 0, 300, GAME_WIDTH, "center")

    for i = 1, #activeSpells do
        local s = activeSpells[i]
        s:draw()
    end
end

function GameOverScene:keypressed(key)
    if key == "return" then
        local userInput = self:processInput()
        if userInput == "q" or userInput == "quit" then
            love.event.quit()
        elseif userInput == "r" or userInput == "restart" then
            self.sceneManager:changeScene("menu")
        end
        input = ""
    end
end
