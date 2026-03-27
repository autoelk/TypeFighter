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
    controller.awaitingIncantation = false
    controller.incantation = nil
    controller.lastAttemptedCardName = nil

    return setmetatable(controller, self)
end

function HumanPlayerController:reset()
    BasePlayerController.reset(self)
    self.drawWord = self.ctx.resourceManager:getRandomWord()
    self.awaitingIncantation = false
    self.incantation = nil
    self.lastAttemptedCardName = nil
    self.player.selectedCard = nil
end

function HumanPlayerController:draw()
    self.renderer:draw({ drawWord = self.drawWord })
end

function HumanPlayerController:generateIncantation(length)
    local result = ""
    while #result < length do
        result = result .. " " .. self.ctx.resourceManager:getRandomWord()
    end

    return string.sub(result, 2)
end

function HumanPlayerController:handleInput(userInput)
    if self.awaitingIncantation then
        if userInput == self.incantation and self.player.selectedCard then
            self.lastAttemptedCardName = self.player.selectedCard.name
            local castResult = self:castCard(self.player.selectedCard)

            self.awaitingIncantation = false
            self.incantation = nil
            self.player.selectedCard = nil

            return castResult
        elseif userInput == "cancel" then
            self.awaitingIncantation = false
            self.incantation = nil
            self.player.selectedCard = nil
            return InputResult.IncantationCancelled
        else
            return InputResult.IncantationMismatch
        end
    end

    if self.drawWord ~= "" and userInput == self.drawWord then
        if not self:drawCard() then
            return InputResult.DrawFail
        end
        return InputResult.DrawSuccess
    end

    for _, card in ipairs(self.player.hand) do
        if userInput == card.name then
            self.player.selectedCard = card
            self.awaitingIncantation = true
            self.incantation = self:generateIncantation(card.incantationLength)
            return InputResult.CardSelected
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
