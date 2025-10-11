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
    player.drawWord = resourceManager:getRandomWord() -- Word the player needs to type to draw
    setmetatable(player, self)
    return player
end

function HumanPlayer:handleInput(userInput)
    if self.drawWord ~= "" and userInput == self.drawWord then
        if not self:drawCard() then
            message2 = "hand full, can't draw"
        end
        self.drawWord = resourceManager:getRandomWord()
        -- Don't return here to allow casting a card named the same as the draw word
    end

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

function HumanPlayer:drawDictWord(libraryX, libraryY)
    lg.setColor(COLORS.YELLOW)
    lg.rectangle("fill", libraryX, libraryY, MINI_CARD_WIDTH, MINI_CARD_HEIGHT)
    lg.setColor(COLORS.BLACK)
    lg.setFont(fontS)
    lg.printf("type", libraryX, libraryY, MINI_CARD_WIDTH, "center")
    lg.setFont(fontL)
    lg.printf(self.drawWord, libraryX, libraryY + 5, MINI_CARD_WIDTH, "center")
    lg.setFont(fontS)
    lg.printf("to draw", libraryX, libraryY + 35, MINI_CARD_WIDTH, "center")
end

function HumanPlayer:other()
    return gameManager:getAIPlayer()
end
