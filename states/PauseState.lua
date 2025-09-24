require "states.BaseState"

-- Pause State
PauseState = {}
setmetatable(PauseState, {__index = BaseState})
PauseState.__index = PauseState

function PauseState:new()
    return setmetatable(BaseState:new(), self)
end

function PauseState:enter()
    message2 = "[Q]uit to menu [ESC] to return"
end

function PauseState:draw()
    lg.setFont(fontXL)
    lg.printf("Pause", 0, 200, 800, "center")
    lg.setFont(fontM)
    lg.printf("[ESC] to return", 0, 300, 800, "center")
end

function PauseState:keypressed(key)
    if key == "escape" then
        self.stateManager:changeState("game")
    elseif key == "return" and self:processInput() == "q" then
        self.stateManager:changeState("menu")
        input = ""
    end
end

