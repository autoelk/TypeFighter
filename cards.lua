cards = {}

cards.name = {}
cards.damage = {}
cards.mana = {}
cards.type = {}
cards.elem = {}
cards.anim = {}

function readCards()
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
        if fileCheck("Assets/Cards/" .. tempTable[6]) then
            cards.anim[i] = newAnimation(love.graphics.newImage("Assets/Cards/" .. tempTable[6]), 160, 160, 1)
        else
            cards.anim[i] = newAnimation(love.graphics.newImage("Assets/Placeholder.png"), 160, 160, 1)
        end
    end
    io.close()
    return numCards
end

function findCard(thingToFind)
    thingToFind = string.lower(thingToFind)
    for i = 1, numCards do
        if cards.name[i] == thingToFind then
            return i
        end
    end
    return 0
end

function displayCard(cardIndex)
    love.graphics.setFont(font)
    local colNum, rowNum = cardIndex % 3, math.ceil(cardIndex / 3)
    if colNum == 0 then
        colNum = 3
    end
    local cardX, cardY = 245 * (colNum - 1) + 65, 317 * (rowNum - 1) + posy
    if cards.elem[cardIndex] == "fire" then
        love.graphics.setColor(232 / 255, 0 / 255, 43 / 255)
    elseif cards.elem[cardIndex] == "earth" then
        love.graphics.setColor(78 / 255, 171 / 255, 84 / 255)
    elseif cards.elem[cardIndex] == "water" then
        love.graphics.setColor(39 / 255, 98 / 255, 176 / 255)
    else
        love.graphics.setColor(160 / 255, 160 / 255, 160 / 255)
    end
    love.graphics.rectangle("fill", cardX, cardY, 180, 252)
    --print image
    love.graphics.setColor(255, 255, 255)
    love.graphics.rectangle("fill", cardX + 10, cardY + 25, 160, 160)
    local spriteNum = math.floor(cards.anim[cardIndex].currentTime / cards.anim[cardIndex].duration * #cards.anim[cardIndex].quads) + 1
    love.graphics.draw(cards.anim[cardIndex].spriteSheet, cards.anim[cardIndex].quads[spriteNum], cardX + 10, cardY + 25, 0, 1)
    --print text
    love.graphics.printf(cards.name[cardIndex], cardX + 10, cardY, 180, "left")
    love.graphics.printf(cards.mana[cardIndex], cardX - 10, cardY, 180, "right")
    if cards.type[cardIndex] == "attack" then
        love.graphics.printf("Deal " .. cards.damage[cardIndex] .. " damage.", cardX + 10, cardY + 200, 180, "left")
    end
end
