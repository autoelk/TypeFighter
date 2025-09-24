require "states.BaseState"

-- Game State (main gameplay)
GameState = {}
setmetatable(GameState, {__index = BaseState})
GameState.__index = GameState

function GameState:new()
    return setmetatable(BaseState:new(), self)
end

function GameState:enter()
    -- Initialize players for gameplay
    player1.health = 50
    player1.healthRegen = 0
    player1.mana = 0
    player1.manaRegen = 1
    player1.spriteNum = 1
    player1.anim.currentTime = 0
    player2.health = 50
    player2.healthRegen = 0
    player2.mana = 0
    player2.manaRegen = 1
    player2.spriteNum = 1
    player2.anim.currentTime = 0
    player2PickCooldown = player2PickSpeed
    player2CastCooldown = player2CastSpeed
    
    -- Set game interface messages
    message = "Type card names to cast them"
    message2 = "[ESC] Pause [Q]uit To Menu"
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
    player1.mana = player1.mana + dt * player1.manaRegen
    if player1.mana < 0 then
        player1.mana = 0
    end
    player2.mana = player2.mana + dt * player2.manaRegen
    if player2.mana < 0 then
        player2.mana = 0
    end
    player1.health = player1.health + dt * player1.healthRegen
    player2.health = player2.health + dt * player2.healthRegen

    -- Player2 AI casting
    player2CastCooldown = player2CastCooldown - dt
    if player2CastCooldown <= 0 then
        local cardToPick = math.random(1, #cards)
        local castChance = math.random(1, 100)
        if cards[cardToPick].deck == 2 and cards[cardToPick].mana <= player2.mana and castChance >= 80 then
            player2:Cast(cardToPick)
            player2CastCooldown = player2CastCooldown + player2CastSpeed
        end
    end
    player2CastCooldown = math.max(player2CastCooldown, 0)

    -- Check for game over
    if player1.health <= 0 or player2.health <= 0 then
        self.stateManager:changeState("gameOver")
    end
end

function GameState:draw()
    -- Display deck
    for i = 1, #deck do
        cards[deck[i]]:DisplayMini((155 * (i - 1)) + 25, 500)
    end

    -- Animations for game
    for i = 1, #cards do
        if cards[i].t > 0 then
            if cards[i].deck == 1 then
                cards[i]:Animate()
            elseif cards[i].deck == 2 then
                cards[i]:Animate()
            end
        end
    end
    
    player1:DrawUI()
    player2:DrawUI()
end

function GameState:keypressed(key)
    if key == "escape" then
        self.stateManager:changeState("pause")
    elseif key == "return" then
        local userInput = self:processInput()
        local location = findCard(userInput)
        
        if location > 0 then
            player1:Cast(location)
        elseif userInput == "q" or userInput == "quit" then
            self.stateManager:changeState("menu")
        else
            message = "Type card names to cast them"
        end
        input = ""
    end
end

