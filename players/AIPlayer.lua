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

    -- Adjust AI properties based on difficulty
    if difficulty == "easy" then
        player.pickSpeed = 8   -- Time between pick attempts
        player.castSpeed = 8   -- Time between cast attempts
        player.castChance = 60 -- Percentage chance to cast when possible
    elseif difficulty == "normal" then
        player.pickSpeed = 5
        player.castSpeed = 5
        player.castChance = 80
    elseif difficulty == "hard" then
        player.pickSpeed = 2
        player.castSpeed = 2
        player.castChance = 95
    end
    player.castCooldown = 0                -- Current cooldown from casting
    player.pickCooldown = player.pickSpeed -- Current cooldown from picking
    player.suppressMessages = true
    setmetatable(player, self)
    return player
end

function AIPlayer:update(dt)
    BasePlayer.update(self, dt)

    if gameManager:getCurrentStateName() == "GameState" then
        self.castCooldown = self.castCooldown - dt
        if self.castCooldown <= 0 then
            local availableCards = {}
            for i = 1, #self.deck do
                if self:canAfford(cards[self.deck[i]].mana) then
                    table.insert(availableCards, self.deck[i])
                end
            end

            if #availableCards > 0 and math.random(100) < self.castChance then
                local cardIndex = availableCards[math.random(1, #availableCards)]
                self:castCard(cardIndex)
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
