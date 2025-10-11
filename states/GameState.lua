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
    gameManager:getHumanPlayer():reset()
    gameManager:getAIPlayer():reset()

    -- Set game interface messages
    message = "type card names to cast them"
    message2 = "[q]uit to menu [esc] pause"

    for i = 1, #cards do
        cards[i]:resetAnimation()
    end
end

function GameState:update(dt)
    local humanPlayer = gameManager:getHumanPlayer()
    local aiPlayer = gameManager:getAIPlayer()

    -- Move projectile animations
    for i = 1, #cards do
        local animDuration = cards[i].anim.frameDuration * #cards[i].anim.quads
        local animDist = aiPlayer.animX - humanPlayer.animX - SPRITE_SIZE
        local animSpeed = animDist / animDuration

        if cards[i].loc == "proj" then
            if cards[i].deck == humanPlayer.id and cards[i].t > 0 then
                cards[i].x = aiPlayer.animX - animSpeed * cards[i].t
                cards[i].y = aiPlayer.animY
            elseif cards[i].deck == aiPlayer.id and cards[i].t > 0 then
                cards[i].x = humanPlayer.animX + animSpeed * cards[i].t
                cards[i].y = humanPlayer.animY
            end
        end
    end

    -- Health and mana regen
    humanPlayer.mana = humanPlayer.mana + dt * humanPlayer.manaRegen
    if humanPlayer.mana < 0 then
        humanPlayer.mana = 0
    end
    humanPlayer.health = humanPlayer.health + dt * humanPlayer.healthRegen
    aiPlayer.mana = aiPlayer.mana + dt * aiPlayer.manaRegen
    if aiPlayer.mana < 0 then
        aiPlayer.mana = 0
    end
    aiPlayer.health = aiPlayer.health + dt * aiPlayer.healthRegen

    -- Player2 AI update
    aiPlayer:update(dt)

    if not humanPlayer.isAlive or not aiPlayer.isAlive then
        self.stateManager:changeState("gameOver")
    end
end

function GameState:draw()
    -- Display decks
    local humanPlayer = gameManager:getHumanPlayer()
    local aiPlayer = gameManager:getAIPlayer()
    local margin = 10

    for i = 1, #humanPlayer.deck do
        cards[humanPlayer.deck[i]]:displayMini(margin, (MINI_CARD_HEIGHT + margin) * i + margin + 100)
    end

    for i = 1, #aiPlayer.deck do
        if aiPlayer.deck[i] == aiPlayer.nextSpell then
            cards[aiPlayer.deck[i]]:displayMini(GAME_WIDTH - MINI_CARD_WIDTH - margin - 40,
                (MINI_CARD_HEIGHT + margin) * i + margin + 100)
        else
            cards[aiPlayer.deck[i]]:displayMini(GAME_WIDTH - MINI_CARD_WIDTH - margin,
                (MINI_CARD_HEIGHT + margin) * i + margin + 100)
        end
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
                animX = animX + SPRITE_SIZE
            end

            card:animate(animX, card.y, card.rotation, animSx, animSy, card.offsetX, card.offsetY)
        end
    end

    humanPlayer:drawUI()
    aiPlayer:drawUI()
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
