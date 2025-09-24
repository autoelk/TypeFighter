-- Base class for all game states
BaseState = {}
BaseState.__index = BaseState

function BaseState:new()
    return setmetatable({}, self)
end

function BaseState:processInput()
    return string.gsub(string.lower(input), "%s+", "")
end

function BaseState:enter() end
function BaseState:exit() end
function BaseState:update(dt) end
function BaseState:draw() end
function BaseState:keypressed(key) end
function BaseState:wheelmoved(x, y) end