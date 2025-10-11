require "players.BasePlayer"

AIPlayer = {}
setmetatable(AIPlayer, {
    __index = BasePlayer
})
AIPlayer.__index = AIPlayer

function AIPlayer:new(id, difficulty)
    local player = BasePlayer:new(id)
    player.x = GAME_WIDTH - 250
    player.y = 375
    player.animX = player.x - SPRITE_SIZE
    player.animY = player.y - 15
    player.uiX = GAME_WIDTH - 25
    player.textOffsetX = -25
    player.mirror = true

    -- AI-specific properties
    player.difficulty = difficulty or "normal"
    if difficulty == "easy" then
        player.pickSpeed = 15  -- Time between pick attempts
        player.castSpeed = 15  -- Time between cast attempts
        player.warningTime = 8 -- Time before casting to show warning
        player.drawSpeed = 10  -- Time between draw attempts
    elseif difficulty == "normal" then
        player.pickSpeed = 7
        player.castSpeed = 7
        player.warningTime = 5
        player.drawSpeed = 7
    elseif difficulty == "hard" then
        player.pickSpeed = 3
        player.castSpeed = 3
        player.warningTime = 2
        player.drawSpeed = 3
    end
    player.castCooldown = 0                -- Current cooldown from casting
    player.pickCooldown = player.pickSpeed -- Current cooldown from picking
    player.warningCooldown = 0             -- Current cooldown for showing warning
    player.drawCooldown = 0                -- Current cooldown from drawing
    player.suppressMessages = true
    player.nextSpell = nil                 -- The next spell the AI plans to cast
    setmetatable(player, self)
    return player
end

function AIPlayer:update(dt)
    BasePlayer.update(self, dt)

    if gameManager:getCurrentStateName() == "CardSelectState" then
        self:updateCardSelectState(dt)
    elseif gameManager:getCurrentStateName() == "GameState" then
        self:updateGameState(dt)
    end
end

function AIPlayer:updateCardSelectState(dt)
    if #self:other().deck >= MAX_DECK_SIZE and self.picks > 0 then
        -- if human player has filled their deck, just fill ours
        self:selectRandomCard()
        return
    end

    self.pickCooldown = self.pickCooldown - dt
    if self.pickCooldown <= 0 and self.picks > 0 then
        self:selectRandomCard()
        self.pickCooldown = self.pickSpeed
    end
end

function AIPlayer:updateGameState(dt)
    self.castCooldown = self.castCooldown - dt
    self.warningCooldown = self.warningCooldown - dt
    self.drawCooldown = self.drawCooldown - dt

    if self.castCooldown <= 0 then
        -- Decide on the next spell to cast
        local availableCards = {}
        for i = 1, #self.hand do
            if self:canAfford(cards[self.hand[i]].mana) then
                table.insert(availableCards, self.hand[i])
            end
        end

        if #availableCards > 0 then
            local cardIndex = availableCards[math.random(1, #availableCards)]
            self.nextSpell = cardIndex
            self.warningCooldown = self.castSpeed - self.warningTime
        end
        self.castCooldown = self.castSpeed
    end

    if self.nextSpell and self.warningCooldown <= 0 then
        self:castCard(self.nextSpell)
        self.nextSpell = nil
    end

    if self.drawCooldown <= 0 and #self.hand < MAX_HAND_SIZE then
        self:drawCard()
        self.drawCooldown = self.drawSpeed
    end
end

function AIPlayer:selectRandomCard()
    local illegalCards = { ["ritual"] = true, ["manatide"] = true }
    local availableCards = {}
    for i = 1, #cards do
        local card = cards[i]
        if card.deck == 0 and not illegalCards[card.name] then
            table.insert(availableCards, i)
        end
    end
    if #availableCards > 0 then
        local cardIdx = availableCards[math.random(1, #availableCards)]
        self:addCard(cardIdx)
    end
end

function AIPlayer:other()
    return gameManager:getHumanPlayer()
end
