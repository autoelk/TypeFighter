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
    if difficulty == "easy" then
        controller.castSpeed = 15 -- Time between cast attempts
        controller.warningTime = 8 -- Time before casting to show warning
        controller.drawSpeed = 10 -- Time between draw attempts
    elseif difficulty == "normal" then
        controller.castSpeed = 7
        controller.warningTime = 5
        controller.drawSpeed = 7
    elseif difficulty == "hard" then
        controller.castSpeed = 3
        controller.warningTime = 2
        controller.drawSpeed = 3
    end
    controller.castCooldown = 0 -- Current cooldown from casting
    controller.warningCooldown = 0 -- Current cooldown for showing warning
    controller.drawCooldown = 0 -- Current cooldown from drawing

    return setmetatable(controller, self)
end

function AIPlayerController:update(dt)
    BasePlayerController.update(self, dt)

    if self.ctx.sceneManager:getCurrentScene().name == "game" then
        self:updateActions(dt)
    end
end

function AIPlayerController:updateActions(dt)
    self.castCooldown = self.castCooldown - dt
    self.warningCooldown = self.warningCooldown - dt
    self.drawCooldown = self.drawCooldown - dt

    if self.castCooldown <= 0 then
        self.player.selectedSpell = self:chooseNextCard()
        if self.player.selectedSpell then
            self.warningCooldown = self.warningTime
            self.castCooldown = self.castSpeed
        end
    end

    if self.player.selectedSpell and self.warningCooldown <= 0 then
        self:castCard(self.player.selectedSpell)
        self.player.selectedSpell = nil
    end

    if self.drawCooldown <= 0 and #self.player.hand < MAX_HAND_SIZE then
        self:drawCard()
        self.drawCooldown = self.drawSpeed
    end
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
