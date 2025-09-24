require "states.BaseState"

-- Menu State
MenuState = {}
setmetatable(MenuState, {__index = BaseState})
MenuState.__index = MenuState

function MenuState:new()
    return setmetatable(BaseState:new(), self)
end

function MenuState:enter()
    input = ""
    message = "Type P to Start"
    message2 = "[P]lay [B]rowse [Q]uit"
    
    -- Reset all card assignments when returning to menu
    for i = 1, #cards do
        cards[i].deck = 0
    end
end

function MenuState:draw()
    lg.setFont(fontXL)
    lg.printf("TypeFighter", 0, 200, 800, "center")
    lg.setFont(fontM)
    lg.printf("[P]lay Game\n[B]rowse Cards\n[Q]uit", 0, 300, 800, "center")
    
    -- Animation
    cards[findCard("torrent")]:Animate(50, 180, 0)
    cards[findCard("fireball")]:Animate(750, 345, 3.14159)
end

function MenuState:keypressed(key)
    if key == "return" then
        local userInput = self:processInput()
        if userInput == "p" or userInput == "play game" then
            self.stateManager:changeState("instructions")
        elseif userInput == "b" then
            self.stateManager:changeState("cardBrowse")
        elseif userInput == "q" or userInput == "quit" then
            love.event.quit()
        end
        input = ""
    end
end

