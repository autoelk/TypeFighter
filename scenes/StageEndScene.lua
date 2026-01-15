require "scenes.BaseScene"

-- Stage End Scene: handles post-battle routing in a linear run
StageEndScene = {}
setmetatable(StageEndScene, {
    __index = BaseScene
})
StageEndScene.__index = StageEndScene

function StageEndScene:new()
    local scene = setmetatable(BaseScene:new(), self)
    scene.name = "stageEnd"
    scene.controlsHint = "[p]lay next level [q]uit"
    scene.message = ""
    return scene
end

function StageEndScene:enter()
    -- Pause underlying game updates while on overlay
    self.sceneManager:pause(true)
    local game = self.sceneManager:getScene("game")
    local p1Alive = game.player1Controller.player.isAlive
    local p2Alive = game.player2Controller.player.isAlive

    if p1Alive and not p2Alive then
        -- Win this stage
        local current = runState.stageIndex
        local total = #runState.stages
        if current < total then
            self.message = "stage " .. current .. " cleared"
        else
            self.message = "final stage cleared"
        end
    else
        -- We should never reach here if the runState is managed correctly
        self.message = "stage end"
    end

    messageRight = self.controlsHint
end

function StageEndScene:exit()
    self.sceneManager:pause(false)
end

function StageEndScene:draw()
    -- Dim the background
    lg.setColor(0, 0, 0, 0.5)
    lg.rectangle("fill", 0, 0, GAME_WIDTH, GAME_HEIGHT)

    -- Draw message
    lg.setColor(COLORS.WHITE)
    lg.setFont(fontXL)
    lg.printf(self.message, 0, 200, GAME_WIDTH, "center")
    lg.setFont(fontM)
    lg.printf(self.controlsHint, 0, 300, GAME_WIDTH, "center")
end

local function restartStage(scene)
    -- Reconfigure GameScene for the current stage and restart
    local game = scene.sceneManager:getScene("game")
    local playerCharName = runState.playerCharacterName
    local oppName = runState:getCurrentOpponent()

    game:setPlayer1(HumanPlayerController:new(BasePlayer:new(characterManager:createCharacter(playerCharName))))
    game:setPlayer2(AIPlayerController:new(BasePlayer:new(characterManager:createCharacter(oppName)), "normal"))
    scene.sceneManager:changeScene("game")
end

function StageEndScene:handleInput(userInput)
    if userInput == "q" or userInput == "quit" then
        love.event.quit()
        return
    end

    if userInput == "p" or userInput == "play" then
        -- Only called on victory; advance or end run
        if runState:hasNextStage() then
            runState:advanceStage()
            restartStage(self)
        else
            runState:endRun()
            self.sceneManager:changeScene("gameOver")
        end
    end
end

return StageEndScene
