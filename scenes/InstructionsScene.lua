require "scenes.BaseScene"
local SceneId = require "enums.SceneId"

-- Instructions Scene
InstructionsScene = {}
setmetatable(InstructionsScene, { __index = BaseScene })
InstructionsScene.__index = InstructionsScene

function InstructionsScene:new(ctx)
    local scene = setmetatable(BaseScene:new(ctx), self)
    scene.name = SceneId.Instructions
    scene.timeLeft = 0
    scene.seen = false
    scene.instructionsText = "choose cards by typing their names.\n\nyou can remove cards from your deck by typing their name again."
    scene.controlsHint = "[play] game, [quit]"
    scene:addAvailableCommand("play", true)
    scene:addAvailableCommand("quit", true)
    return scene
end

function InstructionsScene:enter()
    if self.seen then
        self.ctx.sceneManager:popScene()
        return
    end
    self.ctx.ui.messageLeft = self.controlsHint
    self.ctx.ui.messageRight = ""
    self.ctx.ui.input = ""
    self.timeLeft = 20
end

function InstructionsScene:update(dt)
    self.timeLeft = self.timeLeft - dt
    if self.timeLeft <= 0 then
        self.ctx.sceneManager:popScene()
    end
end

function InstructionsScene:draw()
    local fonts = self.ctx.fonts
    -- Dim the background
    lg.setColor(0, 0, 0, 0.5)
    lg.rectangle("fill", 0, 0, GAME_WIDTH, GAME_HEIGHT)
    lg.setColor(COLORS.WHITE)

    local margin = 8
    local width = 400
    local height = 320
    local startX = (GAME_WIDTH - width) / 2
    lg.setFont(fonts.fontM)
    lg.setColor(COLORS.BLACK)
    lg.rectangle("fill", startX, 150, width, height)
    lg.setColor(COLORS.WHITE)
    lg.printf(self.instructionsText, startX + margin, 160, width - 2 * margin, "center")
end

function InstructionsScene:exit()
    self.seen = true
    self.ctx.ui.messageRight = ""

    -- Revert to control hint of scene from below
    local currentScene = self.ctx.sceneManager:getCurrentScene()
    if currentScene then
        self.ctx.ui.messageLeft = currentScene.controlsHint
    else
        self.ctx.ui.messageLeft = self.controlsHint
    end
end

function InstructionsScene:keypressed(key)
    BaseScene.keypressed(self, key)
    
    if key == "escape" then
        self.ctx.sceneManager:popScene()
    end
end

function InstructionsScene:handleInput(userInput)
    if userInput == "play" then
        self.ctx.sceneManager:popScene()
    elseif userInput == "quit" then
        self.ctx.sceneManager:popScene()
        self.ctx.sceneManager:popScene()
    end
end
