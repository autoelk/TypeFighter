local InputResult = require "enums.InputResult"
require "players.HumanPlayerRenderer"

HumanPlayerController = {}
setmetatable(HumanPlayerController, {
    __index = BasePlayerController
})
HumanPlayerController.__index = HumanPlayerController

function HumanPlayerController:new(ctx, player)
    local controller = BasePlayerController:new(ctx, player, HumanPlayerRenderer:new(ctx, player))
    controller.isHuman = true
    controller.drawWord = ctx.resourceManager:getRandomWords(1)[1]
    controller.incantation = nil
    controller.lastAttemptedCardName = nil

    return setmetatable(controller, self)
end

function HumanPlayerController:reset()
    BasePlayerController.reset(self)
    self.drawWord = self.ctx.resourceManager:getRandomWords(1)[1]
    self.incantation = nil
    self.lastAttemptedCardName = nil
end

function HumanPlayerController:draw()
    self.renderer:draw(self.drawWord)
end

function HumanPlayerController:generateIncantation(length)
    local result = ""
    for i = 1, length do
        result = result .. " " .. self.player.wordBank[math.random(1, #self.player.wordBank)]
    end
    return string.sub(result, 2)
end

function HumanPlayerController:handleInput(userInput)
    if self.drawWord ~= "" and userInput == self.drawWord then
        if not self:drawCard() then
            return InputResult.DrawFail
        end
        return InputResult.DrawSuccess
    end

    for _, card in ipairs(self.player.hand) do
        if userInput == card.name then
            self.player.selectedCard = card
            table.remove(self.player.hand, indexOf(self.player.hand, card))
            self.incantation = self:generateIncantation(card.incantationLength)
            return InputResult.CardSelected
        end
    end
    
    return InputResult.Unknown
end

function HumanPlayerController:handleIncantationInput(userInput)
    if userInput == self.incantation and self.player.selectedCard then
        self.lastAttemptedCardName = self.player.selectedCard.name
        local castResult = self:castSelectedCard()
        self.incantation = nil

        return castResult
    elseif userInput == "quit" or userInput == "cancel" then
        self.incantation = nil
        table.insert(self.player.hand, self.player.selectedCard)
        self.player.selectedCard = nil
        return InputResult.IncantationCancelled
    else
        return InputResult.IncantationMismatch
    end
end

function HumanPlayerController:drawCard()
    local drawResult = self.player:drawCard()
    if drawResult then
        self.drawWord = self.ctx.resourceManager:getRandomWords(1)[1]
    end
    return drawResult
end
