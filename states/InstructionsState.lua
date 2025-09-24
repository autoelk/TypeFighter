require "states.BaseState"

-- Instructions State
InstructionsState = {}
setmetatable(InstructionsState, {__index = BaseState})
InstructionsState.__index = InstructionsState

function InstructionsState:new()
    local state = setmetatable(BaseState:new(), self)
    state.endTime = 0
    return state
end

function InstructionsState:enter()
    message2 = "[p] to skip [q] to go back"
    self.endTime = gameTime + 20
end

function InstructionsState:update(dt)
    if gameTime >= self.endTime then
        self.stateManager:changeState("cardSelect")
    end
end

function InstructionsState:draw()
    lg.setFont(fontM)
    lg.setColor(colors.black)
    lg.rectangle("fill", 200, 150, 400, 300)
    lg.setColor(colors.white)
    lg.printf(
        "choose 5 cards by typing their names before player2 can chose them. you can remove cards from your deck by typing their name again. when you are done, type p to start.",
        210, 160, 380, "center")
end

function InstructionsState:keypressed(key)
    if key == "return" then
        local userInput = self:processInput()
        if userInput == "p" or userInput == "play game" then
            self.stateManager:changeState("cardSelect")
        elseif userInput == "q" then
            self.stateManager:changeState("menu")
        end
        input = ""
    end
end

