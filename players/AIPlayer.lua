require "players.BasePlayer"

AIPlayer = {}
setmetatable(AIPlayer, {
    __index = BasePlayer
})
AIPlayer.__index = AIPlayer

function AIPlayer:new(playerNumber, difficulty)
    local player = BasePlayer:new(playerNumber)

    -- AI-specific properties
    player.difficulty = difficulty or "normal"
    if difficulty == "easy" then
        player.pickSpeed = 15  -- Time between pick attempts
        player.castSpeed = 15  -- Time between cast attempts
        player.warningTime = 8 -- Time before casting to show warning
    elseif difficulty == "normal" then
        player.pickSpeed = 7
        player.castSpeed = 7
        player.warningTime = 5
    elseif difficulty == "hard" then
        player.pickSpeed = 3
        player.castSpeed = 3
        player.warningTime = 2
    end
    player.castCooldown = 0                -- Current cooldown from casting
    player.pickCooldown = player.pickSpeed -- Current cooldown from picking
    player.warningCooldown = 0             -- Current cooldown for showing warning
    player.suppressMessages = true
    player.nextSpell = nil                 -- The next spell the AI plans to cast
    setmetatable(player, self)
    return player
end

function AIPlayer:update(dt)
    BasePlayer.update(self, dt)

    if gameManager:getCurrentStateName() == "GameState" then
        self.castCooldown = self.castCooldown - dt
        self.warningCooldown = self.warningCooldown - dt
        if self.castCooldown <= 0 then
            if self.nextSpell then
                self:castCard(self.nextSpell)
                self.nextSpell = nil
                self.warningCooldown = self.castSpeed - self.warningTime
            end

            -- Decide on the next spell to cast
            local availableCards = {}
            for i = 1, #self.deck do
                if self:canAfford(cards[self.deck[i]].mana) then
                    table.insert(availableCards, self.deck[i])
                end
            end

            if #availableCards > 0 then
                local cardIndex = availableCards[math.random(1, #availableCards)]
                self.nextSpell = cardIndex
            end
            self.castCooldown = self.castSpeed
        end
    elseif gameManager:getCurrentStateName() == "CardSelectState" then
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

function AIPlayer:drawUI()
    BasePlayer.drawUI(self)

    -- Show next spell to be cast
    if self.nextSpell and self.warningCooldown <= 0 then
        -- TODO: Don't use hardcoded position
        cards[self.nextSpell]:displayMini(540, 330 - 100)
    end
end
