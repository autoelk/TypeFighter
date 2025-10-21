local InputResult = require "enums.InputResult"

HumanPlayerController = {}
setmetatable(HumanPlayerController, {
    __index = BasePlayerController,
})
HumanPlayerController.__index = HumanPlayerController

function HumanPlayerController:new(player)
    local controller = BasePlayerController:new(player)
    controller.x = 250
    controller.y = 375
    controller.mirror = false

    controller.uiX = 25
    controller.textOffsetX = 30

    controller.idleAnim = resourceManager:newAnimation("wizardIdle")
    controller.deathAnim = resourceManager:newAnimation("wizardDeath")
    controller.castAnim = resourceManager:newAnimation("wizardCast")

    controller.drawWord = resourceManager:getRandomWord()

    return setmetatable(controller, self)
end

function HumanPlayerController:draw()
    BasePlayerController.draw(self)
    local margin = 10

    if #self.player.hand < MAX_HAND_SIZE then
        self:drawDictWord(margin,
            (MINI_CARD_HEIGHT + margin) * (#self.player.hand + 1) + 100)
    end
end

function HumanPlayerController:drawDictWord(libraryX, libraryY)
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
