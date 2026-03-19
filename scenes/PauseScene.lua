require "scenes.BaseScene"

-- Pause Scene
PauseScene = {}
setmetatable(PauseScene, { __index = BaseScene })
PauseScene.__index = PauseScene

function PauseScene:new(ctx)
    local scene = setmetatable(BaseScene:new(ctx), self)
    scene.name = "pause"
    scene.controlsHint = "[q]uit to menu [esc] to return"
    return scene
end

function PauseScene:enter()
    self.ctx.sceneManager:pause(true)
    self.ctx.ui.messageLeft = ""
    self.ctx.ui.messageRight = self.controlsHint
end

function PauseScene:exit()
    self.ctx.sceneManager:pause(false)
end

function PauseScene:draw()
    local fonts = self.ctx.fonts
    -- Dim the background
    lg.setColor(0, 0, 0, 0.5)
    lg.rectangle("fill", 0, 0, GAME_WIDTH, GAME_HEIGHT)
    
    -- Draw pause text on top
    lg.setColor(COLORS.WHITE)
    lg.setFont(fonts.fontXL)
    lg.printf("pause", 0, 200, GAME_WIDTH, "center")
    lg.setFont(fonts.fontM)
    lg.printf("[esc] to return", 0, 300, GAME_WIDTH, "center")
end

function PauseScene:keypressed(key)
    if key == "escape" then
        self.ctx.sceneManager:popScene()
    end
end

function PauseScene:handleInput(userInput)
    if userInput == "q" then
        self.ctx.sceneManager:changeScene("menu")
    end
end
