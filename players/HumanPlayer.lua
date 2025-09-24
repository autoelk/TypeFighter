require "players.BasePlayer"

HumanPlayer = {}
setmetatable(HumanPlayer, {__index = BasePlayer})
HumanPlayer.__index = HumanPlayer

function HumanPlayer:new(playerNumber)
    local player = BasePlayer:new(playerNumber)
    setmetatable(player, self)
    return player
end

function HumanPlayer:handleInput(userInput)
    -- Find and cast card based on user input
    local cardIndex = findCard(userInput)
    if cardIndex > 0 then
        return self:Cast(cardIndex)
    else
        -- Handle other commands like quit
        if userInput == "q" or userInput == "quit" then
            return "quit"
        end
        return false
    end
end
