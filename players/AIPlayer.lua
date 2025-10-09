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
    player.castCooldown = 0 -- Current cooldown from casting

    -- Card picking properties for selection phase
    player.pickCooldown = 5 -- Start with initial cooldown
    player.pickSpeed = 5 -- Time between pick attempts

    -- Adjust AI properties based on difficulty
    if difficulty == "easy" then
        player.castSpeed = 3 -- Time between cast attempts
        player.castChance = 60 -- Percentage chance to cast when possible
    elseif difficulty == "normal" then
        player.castSpeed = 2
        player.castChance = 80
    elseif difficulty == "hard" then
        player.castSpeed = 1.5
        player.castChance = 95
    end

    player.suppressMessages = true
    setmetatable(player, self)
    return player
end

function AIPlayer:update(dt)
    BasePlayer.update(self, dt)
    -- Update AI casting cooldown
    self.castCooldown = self.castCooldown - dt

    if self.castCooldown <= 0 then
        self:attemptCast()
        self.castCooldown = self.castSpeed
    end
end

function AIPlayer:attemptCast()
    local availableCards = {}
    for i = 1, #cards do
        local card = cards[i]
        if card.deck == self.num and self:canAfford(card.mana) then
            table.insert(availableCards, i)
        end
    end

    if #availableCards == 0 then
        return false
    end

    -- Random chance to cast
    local castChance = math.random(1, 100)
    if castChance < self.castChance then
        -- Select a card to cast (currently random, could be improved with strategy)
        local cardIndex = availableCards[math.random(1, #availableCards)]
        return self:castCard(cardIndex)
    end

    return false
end

-- Card selection phase methods
function AIPlayer:updateCardSelection(dt, opponentPicks)
    -- Adjust pick speed based on opponent's remaining picks
    self.pickSpeed = opponentPicks + 1

    -- Update pick cooldown
    self.pickCooldown = self.pickCooldown - dt

    if self.pickCooldown <= 0 and self.picks > 0 then
        if self:attemptCardPick() then
            self.pickCooldown = self.pickSpeed
        end
    end

    self.pickCooldown = math.max(self.pickCooldown, 0)
end

function AIPlayer:attemptCardPick()
    -- Find available cards to pick
    local availableCards = {}

    for i = 1, #cards do
        local card = cards[i]
        if card.deck == 0 and card.name ~= "ritual" and card.name ~= "manatide" then
            table.insert(availableCards, i)
        end
    end

    if #availableCards > 0 then
        local cardIndex = availableCards[math.random(1, #availableCards)]
        cards[cardIndex].deck = self.num
        self.picks = self.picks - 1
        return true
    end

    return false
end
