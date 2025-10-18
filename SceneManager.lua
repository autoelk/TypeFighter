-- Manages different game scenes and transitions between them
SceneManager = {}
SceneManager.__index = SceneManager

function SceneManager:new()
    return setmetatable({
        states = {},
        currentState = nil,
        currentStateName = nil,
        previousState = nil
    }, self)
end

function SceneManager:addState(name, state)
    self.states[name] = state
    state.sceneManager = self
end

function SceneManager:changeState(stateName)
    if self.currentState and self.currentState.exit then
        self.currentState:exit()
    end

    self.previousState = self.currentState
    self.currentState = self.states[stateName]
    self.currentStateName = stateName

    if self.currentState and self.currentState.enter then
        self.currentState:enter()
    end
end

function SceneManager:getCurrentState()
    return self.currentState
end

function SceneManager:getCurrentStateName()
    return self.currentStateName
end

function SceneManager:update(dt)
    if self.currentState and self.currentState.update then
        self.currentState:update(dt)
    end
end

function SceneManager:draw()
    if self.currentState and self.currentState.draw then
        self.currentState:draw()
    end
end

function SceneManager:keypressed(key)
    if self.currentState and self.currentState.keypressed then
        self.currentState:keypressed(key)
    end
end

function SceneManager:wheelmoved(x, y)
    if self.currentState and self.currentState.wheelmoved then
        self.currentState:wheelmoved(x, y)
    end
end
