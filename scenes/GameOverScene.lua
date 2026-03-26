require "scenes.BaseScene"
local SceneId = require "enums.SceneId"

-- Game Over Scene
-- TODO: Include a run summary/stats
GameOverScene = {}
setmetatable(GameOverScene, {
    __index = BaseScene
})
GameOverScene.__index = GameOverScene

function GameOverScene:new(ctx)
    local scene = setmetatable(BaseScene:new(ctx), self)
    scene.name = SceneId.GameOver
    scene.gameOverMessage = ""
    scene.controlsHint = "[restart], [quit]"
    scene.availableCommands = { "restart", "quit" }
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
    lg.printf("[restart]\n[quit]", 0, 300, GAME_WIDTH, "center")
end

function GameOverScene:handleInput(userInput)
    if userInput == "quit" then
        love.event.quit()
    elseif userInput == "restart" then
        self.ctx.sceneManager:changeScene(SceneId.Menu)
    end
end
