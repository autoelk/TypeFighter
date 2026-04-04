require "scenes.BaseScene"
local SceneId = require "enums.SceneId"

-- Pause Scene
PauseScene = {}
setmetatable(PauseScene, { __index = BaseScene })
PauseScene.__index = PauseScene

function PauseScene:new(ctx)
    local scene = setmetatable(BaseScene:new(ctx), self)
    scene.name = SceneId.Pause
    scene.controlsHint = "[resume] game, [quit] to menu"
    scene:addAvailableCommand("resume", true)
    scene:addAvailableCommand("quit", true)

    scene.prevUI = {
        messageLeft = "",
        messageRight = "",
        input = "",
    }
    return scene
end

function PauseScene:enter()
    self.ctx.sceneManager:pause(true)

    self.prevUI.messageLeft = self.ctx.ui.messageLeft
    self.prevUI.messageRight = self.ctx.ui.messageRight
    self.prevUI.input = self.ctx.ui.input
    self.ctx.ui.messageLeft = self.controlsHint
    self.ctx.ui.messageRight = ""
    self.ctx.ui.input = ""
end

function PauseScene:exit()
    self.ctx.ui.messageLeft = self.prevUI.messageLeft
    self.ctx.ui.messageRight = self.prevUI.messageRight
    self.ctx.ui.input = self.prevUI.input
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
    lg.printf("[resume]\n[quit]", 0, 300, GAME_WIDTH, "center")
end

function PauseScene:keypressed(key)
    BaseScene.keypressed(self, key)
    
    if key == "escape" then
        self.ctx.sceneManager:popScene()
    end
end

function PauseScene:handleInput(userInput)
    if userInput == "quit" then
        self.ctx.runState:endRun()
        self.ctx.sceneManager:changeScene(SceneId.Menu)
    elseif userInput == "resume" then
        self.ctx.sceneManager:popScene()
    end
end
