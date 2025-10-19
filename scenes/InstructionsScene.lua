require "scenes.BaseScene"

-- Instructions Scene
InstructionsScene = {}
setmetatable(InstructionsScene, { __index = BaseScene })
InstructionsScene.__index = InstructionsScene

function InstructionsScene:new()
    local scene = setmetatable(BaseScene:new(), self)
    scene.name = "instructions"
    scene.timeLeft = 0
    scene.seen = false
    scene.instructionsText = "choose " ..
        MAX_DECK_SIZE ..
        " cards by typing their names.\n\nyou can remove cards from your deck by typing their name again."
    scene.controlsHint = "[p] to continue [q] to go back"
    return scene
end

function InstructionsScene:enter()
    if self.seen then
        self.sceneManager:popScene()
        return
    end
    messageRight = self.controlsHint
    self.timeLeft = 20
end

function InstructionsScene:update(dt)
    self.timeLeft = self.timeLeft - dt
    if self.timeLeft <= 0 then
        self.sceneManager:popScene()
    end
end

function InstructionsScene:draw()
    -- Dim the background
    lg.setColor(0, 0, 0, 0.5)
    lg.rectangle("fill", 0, 0, GAME_WIDTH, GAME_HEIGHT)
    lg.setColor(COLORS.WHITE)

    local margin = 10
    local width = 400
    local height = 320
    local startX = (GAME_WIDTH - width) / 2
    lg.setFont(fontM)
    lg.setColor(COLORS.BLACK)
    lg.rectangle("fill", startX, 150, width, height)
    lg.setColor(COLORS.WHITE)
    lg.printf(self.instructionsText, startX + margin, 160, width - 2 * margin, "center")
end

function InstructionsScene:exit()
    self.seen = true
    messageRight = self.sceneManager:getScene("cardSelect").controlsHint
end

function InstructionsScene:keypressed(key)
    if key == "return" then
        local userInput = self:processInput()
        if userInput == "p" or userInput == "play game" then
            self.sceneManager:popScene()
        elseif userInput == "q" then
            self.sceneManager:changeScene("menu")
        end
        input = ""
    end
end
