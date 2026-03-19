require "scenes.BaseScene"

-- Game Over Scene
-- TODO: Include a run summary/stats
GameOverScene = {}
setmetatable(GameOverScene, {
    __index = BaseScene
})
GameOverScene.__index = GameOverScene

function GameOverScene:new(ctx)
    local scene = setmetatable(BaseScene:new(ctx), self)
    scene.name = "gameOver"
    scene.gameOverMessage = ""
    scene.controlsHint = "[r]estart [q]uit"
    return scene
end

function GameOverScene:enter()
    self.ctx.ui.messageLeft = ""
    self.ctx.ui.messageRight = self.controlsHint
    self.gameOverMessage = "game over"
end

function GameOverScene:draw()
    local fonts = self.ctx.fonts
    -- Dim the background
    lg.setColor(COLORS.BLACK)
    lg.rectangle("fill", 0, 0, GAME_WIDTH, GAME_HEIGHT)

    -- Draw game over text on top
    lg.setColor(COLORS.WHITE)
    lg.setFont(fonts.fontXL)
    lg.printf(self.gameOverMessage, 0, 200, GAME_WIDTH, "center")
    lg.setFont(fonts.fontM)
    lg.printf("[r]estart\n[q]uit", 0, 300, GAME_WIDTH, "center")
end

function GameOverScene:handleInput(userInput)
    if userInput == "q" or userInput == "quit" then
        love.event.quit()
    elseif userInput == "r" or userInput == "restart" then
        self.ctx.sceneManager:changeScene("menu")
    end
end
