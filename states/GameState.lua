require "states.BaseState"

-- Game State (main gameplay)
GameState = {}
setmetatable(GameState, {
    __index = BaseState
})
GameState.__index = GameState

function GameState:new()
    return setmetatable(BaseState:new(), self)
end

function GameState:enter()
    gameManager.currentState = "GameState"
    -- Initialize players for gameplay
    local player1 = gameManager:getPlayer(1)
    local player2 = gameManager:getPlayer(2)
    player1.health = 50
    player1.healthRegen = 0
    player1.mana = 0
    player1.manaRegen = 1
    player1.spriteNum = 1
    player1.anim.currentFrame = 1
    player1.anim.accumulator = 0
    player1.isAlive = true
    player2.health = 50
    player2.healthRegen = 0
    player2.mana = 0
    player2.manaRegen = 1
    player2.spriteNum = 1
    player2.anim.currentFrame = 1
    player2.anim.accumulator = 0
    player2.isAlive = true

    -- Set game interface messages
    message = "type card names to cast them"
    message2 = "[q]uit to menu [esc] pause"

    for i = 1, #cards do
        cards[i]:resetAnimation()
    end
end

function GameState:update(dt)
    -- Move projectile animations
    for i = 1, #cards do
        if cards[i].loc == "proj" then
            if cards[i].deck == 1 and cards[i].t > 0 then
                cards[i].x = 540 - 280 * cards[i].t
                cards[i].y = 300
            elseif cards[i].deck == 2 and cards[i].t > 0 then
                cards[i].x = 100 + 280 * cards[i].t
                cards[i].y = 300
            end
        end
    end

    -- Health and mana regen
    local player1 = gameManager:getPlayer(1)
    local player2 = gameManager:getPlayer(2)
    player1.mana = player1.mana + dt * player1.manaRegen
    if player1.mana < 0 then
        player1.mana = 0
    end
    player1.health = player1.health + dt * player1.healthRegen
    player2.mana = player2.mana + dt * player2.manaRegen
    if player2.mana < 0 then
        player2.mana = 0
    end
    player2.health = player2.health + dt * player2.healthRegen

    -- Player2 AI update
    player2:update(dt)

    if not player1.isAlive or not player2.isAlive then
        self.stateManager:changeState("gameOver")
    end
end

function GameState:draw()
    -- Display human player's deck
    local deck = gameManager:getHumanPlayer().deck
    for i = 1, #deck do
        local margin = 25
        local x = margin + (MINI_CARD_WIDTH + margin) * (i - 1)
        local y = GAME_HEIGHT - MINI_CARD_HEIGHT - 40
        cards[deck[i]]:displayMini(x, y)
    end

    -- Animations for game
    for i = 1, #cards do
        if cards[i].t > 0 then
            local card = cards[i]
            local animX = card.x
            local animSx = card.scale
            local animSy = card.scale

            -- Handle deck-specific positioning (mirroring for player 2)
            if card.deck == 2 then
                animSx = animSx * -1
                animX = animX + SCALED_SPRITE_SIZE
            end

            card:animate(animX, card.y, card.rotation, animSx, animSy, card.offsetX, card.offsetY)
        end
    end

    local player1 = gameManager:getPlayer(1)
    local player2 = gameManager:getPlayer(2)
    player1:drawUI()
    player2:drawUI()
end

function GameState:keypressed(key)
    if key == "escape" then
        self.stateManager:changeState("pause")
    elseif key == "return" then
        local userInput = self:processInput()
        local humanPlayer = gameManager:getHumanPlayer()
        if humanPlayer then
            local result = humanPlayer:handleInput(userInput)

            if result == "quit" then
                self.stateManager:changeState("menu")
            elseif result == "unknown_card" then
                message = "type card names to cast them"
            elseif result == "insufficient_mana" then
            elseif result == "not_your_card" then
                message = "that card is not in your deck"
            elseif result == "cannot_cast" then
            end
        end
        input = ""
    end
end
