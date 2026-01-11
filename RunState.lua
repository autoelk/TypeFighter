RunState = {}
RunState.__index = RunState

function RunState:new()
    local rs = setmetatable({}, self)
    rs.active = false
    rs.stageIndex = 0
    rs.stages = {}
    rs.playerCharacterName = nil
    return rs
end

-- Initialize a new run with a simple linear list of encounters
-- opponentNames: array of character names for opponents (e.g., {"wizard", "wizard", ...})
function RunState:startRun(playerCharacterName, opponentNames)
    self.active = true
    self.playerCharacterName = playerCharacterName
    self.stages = opponentNames or { "wizard", "wizard", "wizard", "wizard", "wizard" }
    self.stageIndex = 1
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
