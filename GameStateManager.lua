GameStateManager = {}
GameStateManager.__index = GameStateManager

function GameStateManager:new()
    return setmetatable({
        states = {},
        currentState = nil,
        previousState = nil
    }, self)
end

function GameStateManager:addState(name, state)
    self.states[name] = state
    state.stateManager = self
end

function GameStateManager:changeState(stateName)
    if self.currentState and self.currentState.exit then
        self.currentState:exit()
    end

    self.previousState = self.currentState
    self.currentState = self.states[stateName]

    if self.currentState and self.currentState.enter then
        self.currentState:enter()
    end
end

function GameStateManager:getCurrentState()
    return self.currentState
end

function GameStateManager:update(dt)
    if self.currentState and self.currentState.update then
        self.currentState:update(dt)
    end
end

function GameStateManager:draw()
    if self.currentState and self.currentState.draw then
        self.currentState:draw()
    end
end

function GameStateManager:keypressed(key)
    if self.currentState and self.currentState.keypressed then
        self.currentState:keypressed(key)
    end
end

function GameStateManager:wheelmoved(x, y)
    if self.currentState and self.currentState.wheelmoved then
        self.currentState:wheelmoved(x, y)
    end
end
