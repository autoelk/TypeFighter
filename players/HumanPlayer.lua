require "players.BasePlayer"

HumanPlayer = {}
setmetatable(HumanPlayer, { __index = BasePlayer })
HumanPlayer.__index = HumanPlayer

function HumanPlayer:new(id)
    local player = BasePlayer:new(id)
    player.x = 250
    player.y = 375
    player.animX = player.x
    player.animY = player.y - 15
    player.uiX = 25
    player.textOffsetX = 30
    player.mirror = false
    setmetatable(player, self)
    return player
end

function HumanPlayer:handleInput(userInput)
    -- Find and cast card based on user input
    local cardIndex = cardFactory:findCard(userInput)
    if cardIndex > 0 then
        return self:castCard(cardIndex)
    else
        -- Handle other commands like quit
        if userInput == "q" or userInput == "quit" then
            return "quit"
        end
        return "unknown_card" -- Return specific reason for failure
    end
end

function HumanPlayer:other()
    return gameManager:getAIPlayer()
end
