require "states.BaseState"

-- Pause State
PauseState = {}
setmetatable(PauseState, { __index = BaseState })
PauseState.__index = PauseState

function PauseState:new()
    return setmetatable(BaseState:new(), self)
end

function PauseState:enter()
    gameManager.currentState = "PauseState"
    message2 = "[q]uit to menu [esc] to return"
end

function PauseState:draw()
    lg.setFont(fontXL)
    lg.printf("pause", 0, 200, GAME_WIDTH, "center")
    lg.setFont(fontM)
    lg.printf("[esc] to return", 0, 300, GAME_WIDTH, "center")
end

function PauseState:keypressed(key)
    if key == "escape" then
        self.stateManager:changeState("game")
    elseif key == "return" and self:processInput() == "q" then
        self.stateManager:changeState("menu")
        input = ""
    end
end
