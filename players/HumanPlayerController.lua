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

    return setmetatable(controller, self)
end

function HumanPlayerController:handleInput(userInput)
    if self.player.drawWord ~= "" and userInput == self.player.drawWord then
        if not self.player:drawCard() then
            return InputResult.DrawFail
        end
        return InputResult.DrawSuccess
    end

    -- Find and cast card based on user input
    for _, card in ipairs(self.player.hand) do
        if userInput == card.name then
            return InputResult.CastCard[self:castCard(card)]
        end
    end

    if userInput == "q" or userInput == "quit" then
        return InputResult.Quit
    end
    return InputResult.Unknown
end

function HumanPlayerController:drawDictWord(libraryX, libraryY)
    lg.setColor(COLORS.YELLOW)
    lg.rectangle("fill", libraryX, libraryY, MINI_CARD_WIDTH, MINI_CARD_HEIGHT)
    lg.setColor(COLORS.BLACK)
    lg.setFont(fontS)
    lg.printf("type", libraryX, libraryY, MINI_CARD_WIDTH, "center")
    lg.setFont(fontL)
    lg.printf(self.player.drawWord, libraryX, libraryY + 5, MINI_CARD_WIDTH, "center")
    lg.setFont(fontS)
    lg.printf("to draw", libraryX, libraryY + 35, MINI_CARD_WIDTH, "center")
end
