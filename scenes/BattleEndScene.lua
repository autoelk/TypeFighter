require "scenes.BaseScene"
local SceneId = require "enums.SceneId"

-- Battle End Scene
BattleEndScene = {}
setmetatable(BattleEndScene, {
    __index = BaseScene
})
BattleEndScene.__index = BattleEndScene

function BattleEndScene:new(ctx)
    local scene = setmetatable(BaseScene:new(ctx), self)
    scene.name = SceneId.BattleEnd
    scene.controlsHint = "[play] next level, [quit]"
    scene:addAvailableCommand("play", true)
    scene:addAvailableCommand("quit", true)
    scene.message = ""
    return scene
end

function BattleEndScene:enter()
    -- Pause underlying game updates while on overlay
    self.ctx.sceneManager:pause(true)
    local game = self.ctx.sceneManager:getScene(SceneId.Battle)
    local p1Alive = game.humanController.player.isAlive
    local p2Alive = game.enemyController.player.isAlive

    if p1Alive and not p2Alive then
        -- Win this stage
        local rs = self.ctx.runState
        local current = rs.stageIndex
        local total = #rs.stages
        if current < total then
            self.message = "stage " .. current .. " cleared"
        else
            self.message = "final stage cleared"
        end
    else
        -- We should never reach here if the runState is managed correctly
        self.message = "stage end"
    end

    self.ctx.ui.input = ""
    self.ctx.ui.messageLeft = self.controlsHint
    self.ctx.ui.messageRight = ""
end

function BattleEndScene:exit()
    self.ctx.sceneManager:pause(false)
end

function BattleEndScene:draw()
    local fonts = self.ctx.fonts
    -- Dim the background
    lg.setColor(0, 0, 0, 0.5)
    lg.rectangle("fill", 0, 0, GAME_WIDTH, GAME_HEIGHT)

    -- Draw message
    lg.setColor(COLORS.WHITE)
    lg.setFont(fonts.fontXL)
    lg.printf(self.message, 0, 200, GAME_WIDTH, "center")
    lg.setFont(fonts.fontM)
    lg.printf(self.controlsHint, 0, 300, GAME_WIDTH, "center")
end

local function restartStage(scene)
    -- Reconfigure BattleScene for the current stage and restart
    local game = scene.ctx.sceneManager:getScene(SceneId.Battle)
    local rs = scene.ctx.runState
    local playerCharName = rs.playerCharacterName
    local oppName = rs:getCurrentOpponent()
    
    game:setHumanController(HumanPlayerController:new(scene.ctx, BasePlayer:new(scene.ctx, scene.ctx.characterManager:createCharacter(playerCharName))))
    game:setEnemyController(AIPlayerController:new(scene.ctx, BasePlayer:new(scene.ctx, scene.ctx.characterManager:createCharacter(oppName)), "normal"))
    scene.ctx.sceneManager:changeScene(SceneId.Battle)
end

function BattleEndScene:handleInput(userInput)
    local rs = self.ctx.runState
    if userInput == "quit" then
        self.ctx.sceneManager:changeScene(SceneId.Menu)
        return
    end

    if userInput == "play" then
        -- Only called on victory; advance or end run
        if rs:hasNextStage() then
            rs:advanceStage()
            restartStage(self)
        else
            rs:endRun()
            self.ctx.sceneManager:changeScene(SceneId.GameOver)
        end
    end
end
