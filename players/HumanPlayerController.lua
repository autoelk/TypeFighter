local InputResult = require "enums.InputResult"

HumanPlayerController = {}
setmetatable(HumanPlayerController, {
    __index = BasePlayerController
})
HumanPlayerController.__index = HumanPlayerController

function HumanPlayerController:new(ctx, player)
    local controller = BasePlayerController:new(ctx, player)
    controller.isHuman = true
    controller.drawWord = ctx.resourceManager:getRandomWord()

    return setmetatable(controller, self)
end

function HumanPlayerController:draw()
    self.renderer:draw({ drawWord = self.drawWord })
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
    
    return InputResult.Unknown
end

function HumanPlayerController:drawCard()
    local drawResult = self.player:drawCard()
    if drawResult then
        self.drawWord = self.ctx.resourceManager:getRandomWord()
    end
    return drawResult
end
