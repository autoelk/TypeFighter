require "states.BaseState"

-- Menu State
MenuState = {}
setmetatable(MenuState, {
    __index = BaseState
})
MenuState.__index = MenuState

function MenuState:new()
    return setmetatable(BaseState:new(), self)
end

function MenuState:enter()
    input = ""
    message = "type p to start"
    message2 = "[p]lay [b]rowse [q]uit"

    -- Reset all card assignments when returning to menu
    for i = 1, #cards do
        cards[i].deck = 0
    end

    cards[cardFactory:findCard("torrent")]:loop()
    cards[cardFactory:findCard("fireball")]:loop()
end

function MenuState:draw()
    lg.setFont(fontXL)
    lg.printf("typefighter", 0, 200, GAME_WIDTH, "center")
    lg.setFont(fontM)
    lg.printf("[p]lay game\n[b]rowse cards\n[q]uit", 0, 300, GAME_WIDTH, "center")

    -- Animation
    local margin = 50
    cards[cardFactory:findCard("torrent")]:animate(margin, 180)
    cards[cardFactory:findCard("fireball")]:animate(GAME_WIDTH - margin, 345, 180)
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
