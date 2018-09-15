local utf8 = require("utf8")

cards = {
    ["name"] = {},
    ["damage"] = {},
    ["mana"] = {},
    ["type"] = {}
}

function readCards()
    --read cards into array cards
    io.input("Assets/Cards/cards.txt")
    numCards = io.read()
    for i=1,numCards do
        io.read()
        cards.name[i] = io.read()
        cards.damage[i] = io.read()
        cards.mana[i] = io.read()
        cards.type[i] = io.read()
    end
    io.close()
end

function love.load()
    fireball = newAnimation(love.graphics.newImage("Assets/Cards/Fireball.png"), 160, 160, 1)
    waterball = newAnimation(love.graphics.newImage("Assets/Cards/Waterball.png"), 160, 160, 1)
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
    gameStarted = true

    readCards()

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
        if utf8.offset(input, - 1) then
            input = string.sub(input, 1, utf8.offset(input, - 1) - 1)
        end
    end
    if key == "return" then
        --take input
        input = string.lower(input)
        if input == "p" or input == "play game" then
            --start game
            gameStarted = false
        else
            --error message
            message = "invalid input"
        end
        input = ""
    end
end

function love.update(dt)
    --animations
    fireball.currentTime = fireball.currentTime + dt
    if fireball.currentTime >= fireball.duration then
        fireball.currentTime = fireball.currentTime - fireball.duration
    end
    waterball.currentTime = waterball.currentTime + dt
    if waterball.currentTime >= waterball.duration then
        waterball.currentTime = waterball.currentTime - waterball.duration
    end
end

function love.draw()
    --background
    love.graphics.draw(background, 0, 0)
    love.graphics.draw(textBox, 0, 570)
    love.graphics.setFont(font) --set font to normal font
    love.graphics.printf(message, 5, 570, love.graphics.getWidth(), "left")
    love.graphics.printf(input, 5, 570, love.graphics.getWidth(), "left")
    if gameStarted == true then
        --title
        love.graphics.draw(mainMenuTextBackground, 0, 205)
        love.graphics.setFont(titleFont) --set font to title font
        love.graphics.printf(title, 0, 200, love.graphics.getWidth(), "center")
        --menu
        love.graphics.setFont(font)
        love.graphics.printf(menu, 0, 300, love.graphics.getWidth(), "center")
        --animation
        local fireballSpriteNum = math.floor(fireball.currentTime / fireball.duration * #fireball.quads) + 1
        love.graphics.draw(fireball.spriteSheet, fireball.quads[fireballSpriteNum], 750, 345, 3.14159, 1)
        local waterballSpriteNum = math.floor(waterball.currentTime / waterball.duration * #waterball.quads) + 1
        love.graphics.draw(waterball.spriteSheet, waterball.quads[waterballSpriteNum], 50, 180, 0, 1)
    end
    love.graphics.draw(person, 200, 400)
end

function newAnimation(image, width, height, duration)
    local animation = {}
    animation.spriteSheet = image;
    animation.quads = {};

    for y = 0, image:getHeight() - height, height do
        for x = 0, image:getWidth() - width, width do
            table.insert(animation.quads, love.graphics.newQuad(x, y, width, height, image:getDimensions()))
        end
    end

    animation.duration = duration or 1
    animation.currentTime = 0

    return animation
end
