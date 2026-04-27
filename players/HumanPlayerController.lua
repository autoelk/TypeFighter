local InputResult = require "enums.InputResult"
local Table = require "util.Table"
require "players.HumanPlayerRenderer"

HumanPlayerController = {}
setmetatable(HumanPlayerController, {
    __index = BasePlayerController
})
HumanPlayerController.__index = HumanPlayerController

function HumanPlayerController:new(ctx, player)
    local controller = BasePlayerController:new(ctx, player, HumanPlayerRenderer:new(ctx, player))
    controller.isHuman = true
    controller.drawWord = nil
    controller.lastAttemptedCardName = nil

    return setmetatable(controller, self)
end

function HumanPlayerController:reset()
    BasePlayerController.reset(self)
    self:generateDrawWord()
    self.incantation = {}
    self.lastAttemptedCardName = nil
end

function HumanPlayerController:draw()
    self.renderer:draw(self.drawWord, #self.incantation > 0)
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
            table.remove(self.player.hand, Table.indexOf(self.player.hand, card))
            local incantation = self:generateIncantation(card.incantationLength)
            if #incantation == 0 then
                self.lastAttemptedCardName = card.name
                return self:castSelectedCard()
            end
            self.incantation = incantation
            return InputResult.CardSelected
        end
    end
    
    return InputResult.Unknown
end

function HumanPlayerController:handleIncantationInput(userInput)
    if userInput == self:getIncantationString() and self.player.selectedCard then
        self.lastAttemptedCardName = self.player.selectedCard.name
        local castResult = self:castSelectedCard()
        self.incantation = {}

        return castResult
    elseif userInput == "quit" or userInput == "cancel" then
        self.incantation = {}
        table.insert(self.player.hand, self.player.selectedCard)
        self.player.selectedCard = nil
        return InputResult.IncantationCancelled
    else
        return InputResult.IncantationMismatch
    end
end

function HumanPlayerController:generateDrawWord()
    self.drawWord = self.player.wordBank[math.random(1, #self.player.wordBank)]
end

function HumanPlayerController:drawCard()
    local drawResult = self.player:drawCard()
    if drawResult then
        self:generateDrawWord()
    end
    return drawResult
end
