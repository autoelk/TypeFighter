require "players.BasePlayer"

HumanPlayer = {}
setmetatable(HumanPlayer, { __index = BasePlayer })
HumanPlayer.__index = HumanPlayer

function HumanPlayer:new(id)
    local player = BasePlayer:new(id)
    player.drawWord = resourceManager:getRandomWord() -- Word the player needs to type to draw
    setmetatable(player, self)
    return player
end

function HumanPlayer:drawCard()
    if BasePlayer.drawCard(self) then
        self.drawWord = resourceManager:getRandomWord()
        return true
    end
    return false
end