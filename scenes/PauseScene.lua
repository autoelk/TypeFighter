require "scenes.BaseScene"

-- Pause Scene
PauseScene = {}
setmetatable(PauseScene, { __index = BaseScene })
PauseScene.__index = PauseScene

function PauseScene:new()
    local scene = setmetatable(BaseScene:new(), self)
    scene.name = "pause"
    return scene
end

function PauseScene:enter()
    message2 = "[q]uit to menu [esc] to return"
end

function PauseScene:draw()
    -- Dim the background
    lg.setColor(0, 0, 0, 0.5)
    lg.rectangle("fill", 0, 0, GAME_WIDTH, GAME_HEIGHT)
    lg.setColor(COLORS.WHITE)

    -- Draw pause text on top
    lg.setFont(fontXL)
    lg.printf("pause", 0, 200, GAME_WIDTH, "center")
    lg.setFont(fontM)
    lg.printf("[esc] to return", 0, 300, GAME_WIDTH, "center")
end

function PauseScene:keypressed(key)
    if key == "escape" then
        self.sceneManager:popScene()
    elseif key == "return" and self:processInput() == "q" then
        self.sceneManager:changeScene("menu")
        input = ""
    end
end
