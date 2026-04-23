RunState = {}
RunState.__index = RunState

function RunState:new(ctx)
    local rs = {
        ctx = ctx,
        active = false,
        stageIndex = nil,
        numStages = 5, -- number of stages in a run
        stages = {}, -- list of opponent names
        humanPlayerController = nil,
    }
    return setmetatable(rs, self)
end

function RunState:startRun(humanPlayerController)
    self.active = true
    self.humanPlayerController = humanPlayerController
    self:generateStages()
    self.stageIndex = 1
end

function RunState:generateStages()
    local enemyCharacters = self.ctx.characterManager:getEnemyCharacters()
    for i = 1, self.numStages do
        table.insert(self.stages, enemyCharacters[math.random(1, #enemyCharacters)])
    end
end

function RunState:isActive()
    return self.active == true
end

function RunState:getCurrentOpponent()
    if not self:isActive() then return nil end
    return self.stages[self.stageIndex]
end

function RunState:hasNextStage()
    return self:isActive() and self.stageIndex < #self.stages
end

function RunState:advanceStage()
    if self:hasNextStage() then
        self.stageIndex = self.stageIndex + 1
        return true
    end
    return false
end

function RunState:endRun()
    self.active = false
end
