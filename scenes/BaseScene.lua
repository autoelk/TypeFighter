-- Base class for all game scenes
BaseScene = {}
BaseScene.__index = BaseScene

function BaseScene:new()
    return setmetatable({}, self)
end

function BaseScene:enter() end

function BaseScene:exit() end

function BaseScene:update(dt) end

function BaseScene:draw() end

-- For single key presses
function BaseScene:keypressed(key) end

-- For handling player text input
function BaseScene:handleInput(userInput) end

function BaseScene:wheelmoved(x, y) end
