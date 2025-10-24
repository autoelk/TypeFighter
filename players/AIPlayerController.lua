local CastResult = require "enums.CastResult"

AIPlayerController = {}
setmetatable(AIPlayerController, {
    __index = BasePlayerController
})
AIPlayerController.__index = AIPlayerController

function AIPlayerController:new(player, difficulty)
    local controller = BasePlayerController:new(player)
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
    controller.nextSpell = nil -- The next spell the AI plans to cast

    return setmetatable(controller, self)
end

function AIPlayerController:drawLibrary()
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
        lg.setFont(fontL)
        lg.printf("DECK", self.libraryX, self.libraryY + 5, MINI_CARD_WIDTH, "center")
    end
end

function AIPlayerController:update(dt)
    BasePlayerController.update(self, dt)

    if sceneManager:getCurrentScene().name == "game" then
        self:updateActions(dt)
    end
end

function AIPlayerController:updateHand(dt)
    local margin = 10
    for i, card in ipairs(self.player.hand) do
        card:update(dt)
        if card == self.nextSpell then
            card:move(self.libraryX - 40, (MINI_CARD_HEIGHT + margin) * i + 100)
        else
            card:move(self.libraryX, (MINI_CARD_HEIGHT + margin) * i + 100)
        end
    end
end

function AIPlayerController:updateActions(dt)
    self.castCooldown = self.castCooldown - dt
    self.warningCooldown = self.warningCooldown - dt
    self.drawCooldown = self.drawCooldown - dt

    if self.castCooldown <= 0 then
        self.nextSpell = self:chooseNextCard()
        if self.nextSpell then
            self.warningCooldown = self.castSpeed - self.warningTime
            self.castCooldown = self.castSpeed
        end
    end

    if self.nextSpell and self.warningCooldown <= 0 then
        self:castCard(self.nextSpell)
        self.nextSpell = nil
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
