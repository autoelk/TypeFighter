local utf8 = require("utf8")

cards = {
    ["name"] = {},
    ["damage"] = {},
    ["mana"] = {},
    ["type"] = {},
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
    for i = 1, #Table do
        print(Table[i])
    end
    return Table
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
    title = "TypeFighter"
    menu = "[P]lay Game"
    input = ""
    message = "Type P to Start"
    gameStage = "menu"
    --read cards into array cards
    io.input("Assets/Cards/cards.txt")
    numCards = io.read()
    for i = 1, numCards do
        local tempTable = split(io.read(), " ")
        cards.name[i] = tempTable[1]
        cards.damage[i] = tempTable[2]
        cards.mana[i] = tempTable[3]
        cards.type[i] = tempTable[4]
        cards.anim[i] = newAnimation(love.graphics.newImage("Assets/Cards/" .. tempTable[5]), 160, 160, 1)
    end
    io.close()

    love.keyboard.setKeyRepeat(true)
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
end

function love.draw()
    --background
    love.graphics.draw(background, 0, 0)
    love.graphics.draw(textBox, 0, 570)
    love.graphics.setFont(font)
    --set font to normal font
    love.graphics.printf(message, 5, 570, love.graphics.getWidth(), "left")
    love.graphics.printf(input, 5, 570, love.graphics.getWidth(), "left")
    if gameStage == "menu" then
        --title
        love.graphics.draw(mainMenuTextBackground, 0, 205)
        love.graphics.setFont(titleFont)
        --set font to title font
        love.graphics.printf(title, 0, 200, love.graphics.getWidth(), "center")
        --menu
        love.graphics.setFont(font)
        love.graphics.printf(menu, 0, 300, love.graphics.getWidth(), "center")
        --animation
        local spriteNum0 = math.floor(cards.anim[1].currentTime / cards.anim[1].duration * #cards.anim[1].quads) + 1
        local spriteNum1 = math.floor(cards.anim[2].currentTime / cards.anim[2].duration * #cards.anim[2].quads) + 1
        love.graphics.draw(cards.anim[1].spriteSheet, cards.anim[1].quads[spriteNum0], 50, 180, 0, 1)
        love.graphics.draw(cards.anim[2].spriteSheet, cards.anim[2].quads[spriteNum1], 750, 345, 3.14159, 1)
    end
    love.graphics.draw(person, 200, 400)
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
