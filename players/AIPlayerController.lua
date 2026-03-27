local CastResult = require "enums.CastResult"

AIPlayerController = {}
setmetatable(AIPlayerController, {
    __index = BasePlayerController
})
AIPlayerController.__index = AIPlayerController

function AIPlayerController:new(ctx, player, difficulty)
    local controller = BasePlayerController:new(ctx, player)
    controller.isHuman = false
    controller.tint = COLORS.RED

    controller.difficulty = difficulty or "normal"
    local wpm = 0
    if difficulty == "easy" then
        wpm = 20
    elseif difficulty == "normal" then
        wpm = 35
    elseif difficulty == "hard" then
        wpm = 70
    end
    controller.secondsPerChar = 60 / (wpm * 5)
    controller.intendedAction = nil -- Action to perform next
    controller.actionTime = 5 -- Wait time before intended action can be performed
    controller.actionBuffer = 0.5 -- Buffer time between actions
    
    return setmetatable(controller, self)
end

function AIPlayerController:update(dt)
    BasePlayerController.update(self, dt)

    if self.ctx.sceneManager:getCurrentScene().name == "game" then
        self:updateActions(dt)
    end
end

function AIPlayerController:updateActions(dt)
    self.actionTime = self.actionTime - dt
    if self.actionTime > 0 then
        return
    end

    if self.intendedAction then
        -- perform the intended action
        if self.intendedAction == "draw" then
            self:drawCard()
            self.actionTime = self.actionBuffer
        elseif self.intendedAction == "incant" then
            self.actionTime = self.actionBuffer
        elseif self.intendedAction == "cast" and self.player.selectedCard then
            self:castCard(self.player.selectedCard)
            self.player.selectedCard = nil
            self.actionTime = self.actionBuffer
        end
        self.intendedAction = nil
    else
        self.intendedAction = self:chooseNextAction()

        -- simulate "typing" the intended action
        if self.intendedAction == "draw" then
            self.actionTime = math.max(0.25, 5 * self.secondsPerChar)
        elseif self.intendedAction == "incant" then
            -- this represents choosing the card
            self.actionTime = math.max(0.25, #self.player.selectedCard.name * self.secondsPerChar)
        elseif self.intendedAction == "cast" and self.player.selectedCard then
            -- this represents typing the incantation in order to cast the card
            self.actionTime = math.max(0.25, #self.incantation * self.secondsPerChar)
        else
            -- if we can't do anything, wait a bit
            self.actionTime = self.actionBuffer
        end
    end
end

function AIPlayerController:chooseNextAction()
    local action = nil
    if #self.player.hand < STARTING_HAND_SIZE then
        action = "draw"
    elseif self.player.selectedCard then
        action = "cast"
    else
        action = "incant"
        self.player.selectedCard = self:chooseNextCard()
        if not self.player.selectedCard then
            action = "draw"
        else
            self.incantation = string.rep(" ", self.player.selectedCard.incantationLength)
        end
    end

    return action
end

function AIPlayerController:chooseNextCard()
    local availableCards = {}
    for _, card in ipairs(self.player.hand) do
        if card:canCast(self.player) == CastResult.Success then
            table.insert(availableCards, card)
        end
    end

    if #availableCards > 0 then
        return availableCards[math.random(1, #availableCards)]
    end
    return nil
end
