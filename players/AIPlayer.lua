require "players.BasePlayer"

AIPlayer = {}
setmetatable(AIPlayer, {
    __index = BasePlayer
})
AIPlayer.__index = AIPlayer

function AIPlayer:new(id, difficulty)
    local player = BasePlayer:new(id)
    player.x = GAME_WIDTH - 250 - SPRITE_SIZE
    player.y = 375

    player.mirror = true
    player.uiX = GAME_WIDTH - 25
    player.textOffsetX = -25
    player.idleAnim = resourceManager:newAnimation("evilWizardIdle")
    player.deathAnim = resourceManager:newAnimation("evilWizardDeath")
    player.castAnim = resourceManager:newAnimation("evilWizardCast")

    -- AI-specific properties
    player.difficulty = difficulty or "normal"
    if difficulty == "easy" then
        player.castSpeed = 15  -- Time between cast attempts
        player.warningTime = 8 -- Time before casting to show warning
        player.drawSpeed = 10  -- Time between draw attempts
    elseif difficulty == "normal" then
        player.castSpeed = 7
        player.warningTime = 5
        player.drawSpeed = 7
    elseif difficulty == "hard" then
        player.castSpeed = 3
        player.warningTime = 2
        player.drawSpeed = 3
    end
    player.castCooldown = 0    -- Current cooldown from casting
    player.warningCooldown = 0 -- Current cooldown for showing warning
    player.drawCooldown = 0    -- Current cooldown from drawing
    player.suppressMessages = true
    player.nextSpell = nil     -- The next spell the AI plans to cast
    setmetatable(player, self)
    return player
end

function AIPlayer:update(dt)
    BasePlayer.update(self, dt)

    if sceneManager:getCurrentSceneName() == "game" then
        self.castCooldown = self.castCooldown - dt
        self.warningCooldown = self.warningCooldown - dt
        self.drawCooldown = self.drawCooldown - dt

        if self.castCooldown <= 0 then
            -- Decide on the next spell to cast
            local availableCards = {}
            for i = 1, #self.hand do
                if self:canAfford(self.hand[i].mana) then
                    table.insert(availableCards, self.hand[i])
                end
            end

            if #availableCards > 0 then
                local card = availableCards[math.random(1, #availableCards)]
                self.nextSpell = card
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
end

function AIPlayer:other()
    return HUMANPLAYER
end
