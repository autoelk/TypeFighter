local utf8 = require("utf8")
require "cards"

cards = {}
deck1, deck2 = {}, {}
pick1, pick2 = 5, 5
-- ban1, ban2 = 2, 2

function inDeck(thingToFind, table)
    for i = 1, #table do
        if thingToFind == table[i] then
            return true
        end
    end
    return false
end

function castSpell(index)
    message = "You cast " .. cards[index].name
    if cards[index].type == "attack" then
        message = "You cast " .. cards[index].name .. " and dealt " .. cards[index].damage .. " damage."
    elseif cards[index].type == "defense" then
        message = "You cast " .. cards[index].name .. " and blocked"
    end
end

function readCards()
    --read each card into array cards
    io.input("Assets/Cards/cards.txt")
    numCards = io.read()
    for i = 1, numCards do
        cards[i] = Card:Create()
    end
    io.close()
end

function love.load()
    background = love.graphics.newImage("Assets/Background.png")
    mainMenuTextBackground = love.graphics.newImage("Assets/MainMenuText.png")
    person = love.graphics.newImage("Assets/Person.png")
    textBox = love.graphics.newImage("Assets/TextBox.png")
    titleFont = love.graphics.newFont("Assets/munro.ttf", 96)
    font = love.graphics.newFont("Assets/munro.ttf", 24)
    --initialize variables
    input = ""
    message = "Type P to Start"
    gameStage = "menu"

    readCards()

    --allow repeating input
    love.keyboard.setKeyRepeat(true)
    --scrolling
    scrollSpeed = 30
    posx, posy = 800 * 0.5, 200
    velx, vely = 0, 0 -- The scroll velocity
end

function love.keypressed(key)
    --erase message
    message = ""
    --textbox
    if key == "backspace" then
        if utf8.offset(input, -1) then
            input = string.sub(input, 1, utf8.offset(input, -1) - 1)
        end
    end
    if key == "return" then
        --take input
        input = string.gsub(string.lower(input), "%s+", "")
        local location = findCard(input)
        --find location of card
        if input == "p" or input == "play game" then
            --start game
            gameStage = "cardSelect"
            input = ""
            message = 'Type "deck" to view current deck'
        elseif location > 0 and gameStage == "cardSelect" then
            --add card to deck
            if pick1 <= 0 then
                message = "You have no picks remaining, type deck to view current"
            elseif inDeck(location, deck1) then
                message = "Sorry, but " .. cards[location].name .. " is already in your deck"
            else
                table.insert(deck1, location)
                message = cards[location].name .. " was added to you deck"
                pick1 = pick1 - 1
            end
        elseif location > 0 and gameStage == "game" then
            --cast the spell
            castSpell(location)
        elseif input == "deck" then
            message = printDeck()
        else
            message = "invalid input" --error message
        end
        input = "" -- clear input
    end
end

function love.update(dt)
    --animations
    for i = 1, numCards do
        cards[i].anim.currentTime = cards[i].anim.currentTime + dt
        if cards[i].anim.currentTime >= cards[i].anim.duration then
            cards[i].anim.currentTime = cards[i].anim.currentTime - cards[i].anim.duration
        end
    end
    --scrolling
    if posy >= 200 then
        posy = 200
    end
    posx = posx + velx * scrollSpeed * dt
    posy = posy + vely * scrollSpeed * dt

    -- Gradually reduce the velocity to create smooth scrolling effect.
    velx = velx - velx * math.min(dt * 10, 1)
    vely = vely - vely * math.min(dt * 10, 1)

    if #deck1 == 5 and #deck2 == 5 then -- switch gamestage to game when both are done picking
        gameStage = "game"
    end
end

function love.draw()
    --background
    love.graphics.draw(background, 0, 0)
    love.graphics.setFont(font)
    love.graphics.draw(person, 100, 320)
    love.graphics.draw(person, 700, 320, 0, -1, 1)
    --set font to normal font
    if gameStage == "menu" then
        --title
        love.graphics.draw(mainMenuTextBackground, 0, 205)
        love.graphics.setFont(titleFont) --set font to title font
        love.graphics.printf("TypeFighter", 0, 200, 800, "center")
        --menu
        love.graphics.setFont(font)
        love.graphics.printf("[P]lay Game", 0, 300, 800, "center")
        -- love.graphics.printf("Music by Eric Matyas www.soundimage.org", 0, 540, 800, "right")
        --animation
        local spriteNum0 = math.floor(cards[findCard("torrent")].anim.currentTime / cards[findCard("torrent")].anim.duration * #cards[findCard("torrent")].anim.quads) + 1
        local spriteNum1 = math.floor(cards[findCard("fireball")].anim.currentTime / cards[findCard("fireball")].anim.duration * #cards[findCard("fireball")].anim.quads) + 1
        love.graphics.draw(cards[findCard("torrent")].anim.spriteSheet, cards[findCard("torrent")].anim.quads[spriteNum0], 50, 180, 0, 1)
        love.graphics.draw(cards[findCard("fireball")].anim.spriteSheet, cards[findCard("fireball")].anim.quads[spriteNum1], 750, 345, 3.14159, 1)
    elseif gameStage == "cardSelect" then --Stage of card selection
        love.graphics.setColor(255, 255, 255) -- reset colors
        --Display card select title
        love.graphics.setFont(titleFont) --set font to title font
        love.graphics.printf("Select Cards", 0, posy - 135, 800, "center")

        for i = 1, numCards do
            Card:Display(i)
        end
    elseif gameStage == "game" then
    end

    --input box at bottom of screen
    love.graphics.draw(textBox, 0, 570)
    love.graphics.printf(message, 5, 570, 800, "left")
    love.graphics.printf(input, 5, 570, 800, "left")
end

function printDeck()
    local deck = ""
    for i = 1, #deck1 do
        deck = deck .. cards[deck1[i]].name .. " "
    end
    if deck == "" then
        deck = "Your deck is currently empty, add cards by typing their names"
    end
    return deck
end

function newAnimation(image, width, height, duration)
    local animation = {}
    animation.spriteSheet = image
    animation.quads = {}

    for y = 0, image:getHeight() - height, height do
        for x = 0, image:getWidth() - width, width do
            table.insert(animation.quads, love.graphics.newQuad(x, y, width, height, image:getDimensions()))
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
    velx = velx + dx * 20
    vely = vely + dy * 20
end
