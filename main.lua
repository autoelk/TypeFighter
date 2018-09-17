local utf8 = require("utf8")

cards = {
    ["name"] = {},
    ["damage"] = {},
    ["mana"] = {},
    ["type"] = {},
    ["elem"] = {},
    ["anim"] = {}
}

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

function love.wheelmoved(dx, dy)
    velx = velx + dx * 20
    vely = vely + dy * 20
end

function findCard(name)
    name = string.lower(name)
    for i = 1, numCards do
        if cards.name[i] == name then
            return i
        end
    end
    return 0
end

function displayCard(cardNum)
    local colNum = cardNum % 3
    if colNum == 0 then
        colNum = 3
    end
    local rowNum = math.ceil(cardNum / 3)
    if cards.elem[cardNum] == "fire" then
        love.graphics.setColor(232 / 255, 0 / 255, 43 / 255)
    elseif cards.elem[cardNum] == "earth" then
        love.graphics.setColor(78 / 255, 171 / 255, 84 / 255)
    elseif cards.elem[cardNum] == "water" then
        love.graphics.setColor(39 / 255, 98 / 255, 176 / 255)
    else
        love.graphics.setColor(160 / 255, 160 / 255, 160 / 255)
    end
    love.graphics.rectangle("fill", 245 * (colNum - 1) + 65, 317 * (rowNum - 1) + posy, 180, 252, 10)
    love.graphics.setColor(255, 255, 255)
    love.graphics.printf(cards.name[cardNum], 245 * (colNum - 1) + 65, 317 * (rowNum - 1) + posy, 180, "left")
    love.graphics.printf(cards.mana[cardNum], 245 * (colNum - 1) + 65, 317 * (rowNum - 1) + posy, 180, "right")
    -- end
end

function castSpell(index)
    message = "You cast " .. cards.name[index]
    if cards.type[index] == "attack" then
        message = "You cast " .. cards.name[index] .. " and dealt " .. cards.damage[index] .. " damage."
    elseif cards.type[index] == "defense" then
        message = "You cast " .. cards.name[index] .. " and blocked"
    end
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
    --read each card into array cards
    io.input("Assets/Cards/cards.txt")
    numCards = io.read()
    for i = 1, numCards do
        local tempTable = split(io.read(), " ")
        cards.name[i] = tempTable[1]
        cards.damage[i] = tempTable[2]
        cards.mana[i] = tempTable[3]
        cards.type[i] = tempTable[4]
        cards.elem[i] = tempTable[5]
        cards.anim[i] = newAnimation(love.graphics.newImage("Assets/Cards/" .. tempTable[6]), 160, 160, 1)
    end
    io.close()

    --allow repeating input
    love.keyboard.setKeyRepeat(true)
    --scrolling
    scrollSpeed = 10
    posx, posy = love.graphics.getWidth() * 0.5, 300
    velx, vely = 0, 0 -- The scroll velocity
end

function love.textinput(t)
    input = input .. t
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
        input = string.lower(input)
        local location = findCard(input)
        --find location of card
        if input == "p" or input == "play game" then
            --start game
            gameStage = "cardSelect"
            input = ""
        elseif location > 0 and gameStage == "cardSelect" then
            --add card to deck
        elseif location > 0 and gameStage == "game" then
            --cast the spell
            castSpell(location)
        else
            message = "invalid input" --error message
        end
        input = "" -- clear input
    end
end

function love.update(dt)
    --animations
    for i = 1, numCards do
        cards.anim[i].currentTime = cards.anim[i].currentTime + dt
        if cards.anim[i].currentTime >= cards.anim[i].duration then
            cards.anim[i].currentTime = cards.anim[i].currentTime - cards.anim[i].duration
        end
    end
    --scrolling
    posx = posx + velx * scrollSpeed * dt
    posy = posy + vely * scrollSpeed * dt

    -- Gradually reduce the velocity to create smooth scrolling effect.
    velx = velx - velx * math.min(dt * 10, 1)
    vely = vely - vely * math.min(dt * 10, 1)
end

function love.draw()
    --background
    love.graphics.draw(background, 0, 0)
    love.graphics.setFont(font)
    love.graphics.draw(person, 200, 400)
    --set font to normal font
    if gameStage == "menu" then
        --title
        love.graphics.draw(mainMenuTextBackground, 0, 205)
        love.graphics.setFont(titleFont) --set font to title font
        love.graphics.printf("TypeFighter", 0, 200, love.graphics.getWidth(), "center")
        --menu
        love.graphics.setFont(font)
        love.graphics.printf("[P]lay Game", 0, 300, love.graphics.getWidth(), "center")
        --animation
        local spriteNum0 = math.floor(cards.anim[1].currentTime / cards.anim[1].duration * #cards.anim[1].quads) + 1
        local spriteNum1 = math.floor(cards.anim[2].currentTime / cards.anim[2].duration * #cards.anim[2].quads) + 1
        love.graphics.draw(cards.anim[1].spriteSheet, cards.anim[1].quads[spriteNum0], 50, 180, 0, 1)
        love.graphics.draw(cards.anim[2].spriteSheet, cards.anim[2].quads[spriteNum1], 750, 345, 3.14159, 1)
    end
    if gameStage == "cardSelect" then --Stage of card selection
        love.graphics.setColor(255, 255, 255) -- reset colors
        --Display card select title
        love.graphics.draw(mainMenuTextBackground, 0, posy - 150)
        love.graphics.setFont(titleFont) --set font to title font
        love.graphics.printf("Select Cards", 0, posy - 135, love.graphics.getWidth(), "center")

        love.graphics.setFont(font)
        -- local extraCards = numCards % 3
        for i = 1, math.ceil(numCards / 3) do
            for j = 1, 3 do
                displayCard(i + j - 1)
            end
        end
        if gameStage == "game" then
        end
    end

    --input box at bottom of screen
    love.graphics.draw(textBox, 0, 570)
    love.graphics.printf(message, 5, 570, love.graphics.getWidth(), "left")
    love.graphics.printf(input, 5, 570, love.graphics.getWidth(), "left")
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
