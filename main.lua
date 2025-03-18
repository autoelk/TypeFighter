local utf8 = require("utf8")
require "cards"
require "player"

cards = {}
deck = {}
-- color palette for the game
colors = {
    red = { 250 / 255, 89 / 255, 52 / 255 },
    orange = { 250 / 255, 121 / 255, 33 / 255 },
    yellow = { 253 / 255, 231 / 255, 76 / 255 },
    green = { 155 / 255, 197 / 255, 61 / 255 },
    blue = { 91 / 255, 192 / 255, 235 / 255 },
    grey = { 77 / 255, 80 / 255, 87 / 255 },
    white = { 1, 1, 1 },
    black = { 0, 0, 0 }
}

function love.load()
    lg = love.graphics
    lk = love.keyboard
    math.randomseed(os.time())

    background = lg.newImage("assets/background.png")
    -- fonts
    fontXL = lg.newFont("assets/munro-small.ttf", 96)
    fontL = lg.newFont("assets/munro-small.ttf", 36)
    fontM = lg.newFont("assets/munro-small.ttf", 24)
    fontS = lg.newFont("assets/munro-small.ttf", 18)
    fontXS = lg.newFont("assets/munro-small.ttf", 15)

    -- read each card into array cards
    io.input("./cards.txt")
    local numCards = io.read()
    for i = 1, numCards do
        cards[i] = Card:Create(i)
    end
    io.close()

    player1 = Player:Create(1)
    player2 = Player:Create(2)

    love.keyboard.setKeyRepeat(true) -- allow repeating input
    Setup()
end

function Setup()
    input = ""
    message = "Type P to Start"
    message2 = "[P]lay [B]rowse [Q]uit"
    gameState = "menu"

    -- player2 (bot) stats
    player2PickSpeed = 5
    player2CastSpeed = 2
    player2PickCooldown = player2PickSpeed
    player2CastCooldown = player2CastSpeed

    -- scrolling
    scrollSpeed = 30
    posy = 10

    -- reset decks
    for i = 1, #cards do
        cards[i].deck = 0
    end

    -- reset players
    player1.health = 50
    player1.healthRegen = 0
    player1.mana = 0
    player1.manaRegen = 1
    player1.spriteNum = 1
    player1.picks = 5
    player1.anim.currentTime = 0
    player2.health = 50
    player2.healthRegen = 0
    player2.mana = 0
    player2.manaRegen = 1
    player2.spriteNum = 1
    player2.picks = 5
    player2.anim.currentTime = 0

    -- reset time
    gameTime = 0
end

function love.keypressed(key)
    -- pause
    if gameState ~= "pause" then
        if key == "escape" then
            storedGameState = gameState
            gameState = "pause"
        end
    else
        if key == "escape" then
            gameState = storedGameState
        end
    end

    -- textbox
    if key == "backspace" then
        if utf8.offset(input, -1) then
            input = string.sub(input, 1, utf8.offset(input, -1) - 1)
        end
    end

    message = "" -- clear message from game to user

    if key == "return" then
        -- take input
        input = string.gsub(string.lower(input), "%s+", "")
        local location = findCard(input) --find location of card
        if gameState == "menu" then
            if input == "p" or input == "play game" then
                -- show instructions
                gameState = "instructions"
                endInstruct = gameTime + 20
                input = ""
            elseif input == "b" then
                gameState = "cardBrowse"
            elseif input == "q" or input == "quit" then
                love.event.quit()
            end
        elseif gameState == "cardBrowse" then
            if input == "q" then
                gameState = "menu"
                Setup()
            end
        elseif gameState == "instructions" then
            if input == "p" or input == "play game" then
                gameState = "cardSelect"
                endInstruct = 0
            elseif input == "q" then
                gameState = "menu"
                Setup()
            end
        elseif gameState == "cardSelect" then
            if location > 0 then
                -- add card to deck
                if cards[location].deck == 1 then
                    cards[location].deck = 0
                    message = "removed " .. cards[location].name
                    player1.picks = player1.picks + 1
                elseif cards[location].deck == 2 then
                    message = cards[location].name .. " is in player2's deck"
                elseif player1.picks <= 0 then
                    message = "no picks remaining"
                else
                    cards[location].deck = 1
                    message = "added " .. cards[location].name
                    player1.picks = player1.picks - 1
                end
            elseif input == "start" or input == "p" then
                if player1.picks > 0 then -- switch gameState to game when both are done picking
                    message = "you have " .. player1.picks .. " picks left"
                elseif player2.picks > 0 then
                    message = "player2 has " .. player2.picks .. " picks left"
                else
                    message = "Game Started"
                    gameState = "game"
                end
            elseif input == "q" or input == "quit" then
                Setup()
                gameState = "menu"
            else
                message = "Type card names to choose them"
            end
        elseif gameState == "game" then
            if location > 0 then
                -- cast the spell
                player1:Cast(location)
            elseif input == "q" or input == "quit" then
                gameState = "cardSelect"
            else
                message = "Type card names to cast them"
            end
        elseif gameState == "pause" then
            gameState = "menu"
            Setup()
        elseif gameState == "over" then
            if input == "q" or input == "quit" then
                love.event.quit()
            elseif input == "r" or input == "restart" then
                Setup()
                gameState = "menu"
            end
        else
            message = "invalid input" -- error message
        end

        input = "" -- clear user input
    end
end

function love.update(dt)
    -- card animations
    for i = 1, #cards do
        cards[i].t = cards[i].t - dt
        if cards[i].t < 0 then
            cards[i].t = 0
        end
        cards[i].anim.currentTime = cards[i].anim.currentTime + dt
        if cards[i].anim.currentTime >= cards[i].anim.duration then
            cards[i].anim.currentTime = cards[i].anim.currentTime - cards[i].anim.duration
        end
    end

    -- death animations
    if player1.health <= 0 then
        player1.anim.currentTime = player1.anim.currentTime + dt
        if player1.anim.currentTime >= player1.anim.duration then
            player1.anim.currentTime = player1.anim.currentTime - player1.anim.duration
        end
    elseif player2.health <= 0 then
        player2.anim.currentTime = player2.anim.currentTime + dt
        if player2.anim.currentTime >= player2.anim.duration then
            player2.anim.currentTime = player2.anim.currentTime - player2.anim.duration
        end
    end

    -- card display positions
    if gameState == "cardBrowse" then
        for i = 1, #cards do
            local colNum, rowNum = i % 4, math.ceil(i / 4)
            if colNum == 0 then
                colNum = 4
            end
            cards[i]:Move(196 * (colNum - 1) + 16, 268 * (rowNum - 1) + posy)
        end
    elseif gameState == "cardSelect" then
        for k, v in pairs(deck) do
            deck[k] = nil
        end
        local cardsGone = 0
        for i = 1, #cards do
            if cards[i].deck == 1 then
                cardsGone = cardsGone + 1
                table.insert(deck, i)
                cards[i]:Move(595, 25 * #deck)
            else
                local colNum, rowNum = (i - cardsGone) % 3, math.ceil((i - cardsGone) / 3)
                if colNum == 0 then
                    colNum = 3
                end
                cards[i]:Move(190 * (colNum - 1) + 10, 262 * (rowNum - 1) + posy)
            end
        end
    elseif gameState == "game" or gameState == "over" then
        -- move projectile animations
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
    end

    -- scrolling boundries
    if posy >= 200 then
        posy = 200
    elseif posy <= (math.ceil(#cards / 3) - 1) * -317 + 25 then
        posy = (math.ceil(#cards / 3) - 1) * -317 + 25
    end

    gameTime = gameTime + dt
    if gameState == "instructions" and gameTime >= endInstruct then
        gameState = "cardSelect"
    end

    -- health and mana regen
    if gameState == "game" then
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
    end

    -- player2 action
    if gameState == "cardSelect" then
        player2PickSpeed = player1.picks + 1
        player2PickCooldown = player2PickCooldown - dt
        if player2PickCooldown <= 0 then
            local cardToPick = math.random(1, #cards)
            if cards[cardToPick].deck == 0 and cards[cardToPick].name ~= "ritual" and player2.picks > 0 then
                cards[cardToPick].deck = 2
                player2.picks = player2.picks - 1
                player2PickCooldown = player2PickCooldown + player2PickSpeed
            end
        end
        player2PickCooldown = math.max(player2PickCooldown, 0)
    elseif gameState == "game" then
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
    end
end

function love.draw()
    -- scale
    scale = math.min(lg.getWidth() / 800, lg.getHeight() / 600)
    lg.scale(scale, scale)
    -- background
    lg.draw(background, 0, 0)
    lg.setFont(fontM)
    -- players
    lg.setColor(colors.red)
    player2:Draw()
    lg.setColor(colors.white)
    player1:Draw()

    if gameState == "menu" then
        lg.setFont(fontXL)
        lg.printf("TypeFighter", 0, 200, 800, "center")
        -- menu
        lg.setFont(fontM)
        lg.printf("[P]lay Game\n[B]rowse Cards\n[Q]uit", 0, 300, 800, "center")
        -- animation
        cards[findCard("torrent")]:Animate(50, 180, 0)
        cards[findCard("fireball")]:Animate(750, 345, 3.14159)
    elseif gameState == "cardBrowse" then
        message2 = "[Q] to go back"
        for i = 1, #cards do
            cards[i]:Display()
        end
    elseif gameState == "instructions" then
        message2 = "[P] to Skip [Q] to go back"
        -- display instructions
        lg.setFont(fontM)
        lg.setColor(colors.black)
        lg.rectangle("fill", 200, 150, 400, 300)
        lg.setColor(colors.white)
        lg.printf(
        "Choose 5 cards by typing their names before player2 can chose them. You can remove cards from your deck by typing their name again. When you are done, type P to start.",
            210, 160, 380, "center")
    elseif gameState == "cardSelect" then --Stage of card selection
        message2 = "[P]lay [Q] to go back"
        for i = 1, #cards do
            if cards[i].deck ~= 1 then
                cards[i]:Display()
            end
        end
        -- draw cards in deck on top
        for i = 1, #cards do
            if cards[i].deck == 1 then
                cards[i]:Display()
            end
        end
    elseif gameState == "game" then
        -- display deck
        for i = 1, #deck do
            cards[deck[i]]:DisplayMini((155 * (i - 1)) + 25, 500)
        end
        if player1.health <= 0 or player2.health <= 0 then
            gameState = "over"
        end
    elseif gameState == "pause" then
        message2 = "[Q] menu [ESC] to return"
        lg.setFont(fontXL)
        lg.printf("Pause", 0, 200, 800, "center")
        -- menu
        lg.setFont(fontM)
        lg.printf("[ESC] to return", 0, 300, 800, "center")
    elseif gameState == "over" then
        if player1.health <= 0 and player2.health <= 0 then
            gameOverMessage = "Tie"
        elseif player1.health <= 0 then
            gameOverMessage = "Player2 Wins"
        elseif player2.health <= 0 then
            gameOverMessage = "Player1 Wins"
        end
        lg.setFont(fontXL)
        lg.printf(gameOverMessage, 0, 200, 800, "center")
        -- menu
        lg.setFont(fontM)
        lg.printf("[R]estart Game\n[Q]uit", 0, 300, 800, "center")
    end

    if gameState == "game" or gameState == "over" then
        -- animations for game
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

    -- input box at bottom of screen
    lg.setColor(colors.black)
    lg.rectangle("fill", 0, 570, 800, 30)
    lg.setFont(fontM)
    lg.setColor(colors.white) -- reset colors
    lg.printf(message, 5, 570, 800, "left")
    lg.printf(message2, -5, 570, 800, "right")
    lg.printf(input, 5, 570, 800, "left")
end

function newAnimation(image, width, height, duration)
    local animation = {}
    animation.spriteSheet = image
    animation.quads = {}

    for y = 0, image:getHeight() - height, height do
        for x = 0, image:getWidth() - width, width do
            table.insert(animation.quads, lg.newQuad(x, y, width, height, image:getDimensions()))
        end
    end
    animation.duration = duration or 1
    animation.currentTime = 0

    return animation
end

function love.textinput(t)
    input = input .. t
end

function split(pString, pPattern)
    local Table = {}
    local fpat = "(.-)" .. pPattern
    local last_end = 1
    local s, e, cap = pString:find(fpat, 1)
    while s do
        if s ~= 1 or cap ~= "" then
            table.insert(Table, cap)
        end
        last_end = e + 1
        s, e, cap = pString:find(fpat, last_end)
    end
    if last_end <= #pString then
        cap = pString:sub(last_end)
        table.insert(Table, cap)
    end
    return Table
end

function fileCheck(file_name)
    local file_found = io.open(file_name, "r")

    if file_found == nil then
        file_found = false
    else
        file_found = true
    end
    return file_found
end

function love.wheelmoved(dx, dy)
    posy = posy + dy * 75
end
