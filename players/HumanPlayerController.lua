local InputResult = require "enums.InputResult"

HumanPlayerController = {}
setmetatable(HumanPlayerController, {
    __index = BasePlayerController
})
HumanPlayerController.__index = HumanPlayerController

function HumanPlayerController:new(player)
    local controller = BasePlayerController:new(player)
    controller.isHuman = true

    controller.drawWord = resourceManager:getRandomWord()

    return setmetatable(controller, self)
end

function HumanPlayerController:drawLibrary()
    if #self.player.hand >= MAX_HAND_SIZE then
        lg.setColor(COLORS.GREY)
        lg.rectangle("fill", self.libraryX, self.libraryY, MINI_CARD_WIDTH, MINI_CARD_HEIGHT)
        lg.setColor(COLORS.WHITE)
        lg.setFont(fontL)
        lg.printf("hand full", self.libraryX, self.libraryY + 5, MINI_CARD_WIDTH, "center")
    else
        lg.setColor(COLORS.YELLOW)
        lg.rectangle("fill", self.libraryX, self.libraryY, MINI_CARD_WIDTH, MINI_CARD_HEIGHT)
        lg.setColor(COLORS.BLACK)
        lg.setFont(fontS)
        lg.printf("type", self.libraryX, self.libraryY, MINI_CARD_WIDTH, "center")
        lg.setFont(fontL)
        lg.printf(self.drawWord, self.libraryX, self.libraryY + 5, MINI_CARD_WIDTH, "center")
        lg.setFont(fontS)
        lg.printf("to draw", self.libraryX, self.libraryY + 35, MINI_CARD_WIDTH, "center")
    end
end

function HumanPlayerController:handleInput(userInput)
    if self.drawWord ~= "" and userInput == self.drawWord then
        if not self:drawCard() then
            return InputResult.DrawFail
        end
        return InputResult.DrawSuccess
    end

    -- Find and cast card based on user input
    for _, card in ipairs(self.player.hand) do
        if userInput == card.name then
            return self:castCard(card)
        end
    end

    if userInput == "q" or userInput == "quit" then
        return InputResult.Quit
    end
    return InputResult.Unknown
end

function HumanPlayerController:drawCard()
    local drawResult = self.player:drawCard()
    if drawResult then
        self.drawWord = resourceManager:getRandomWord()
    end
    return drawResult
end
