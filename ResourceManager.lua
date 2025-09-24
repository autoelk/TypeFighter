ResourceManager = {}
ResourceManager.__index = ResourceManager

function ResourceManager:new()
    local manager = {
        images = {},
        fonts = {},
        sounds = {},
        animations = {}
    }
    setmetatable(manager, self)
    return manager
end

function ResourceManager:loadFont(name, path, size)
    if not self.fonts[name] then
        self.fonts[name] = love.graphics.newFont(path, size)
    end
    return self.fonts[name]
end

function ResourceManager:getFont(name)
    return self.fonts[name]
end

function ResourceManager:loadImage(name, path)
    if not self.images[name] then
        self.images[name] = love.graphics.newImage(path)
    end
    return self.images[name]
end

function ResourceManager:getImage(name)
    return self.images[name]
end

function ResourceManager:loadAnimation(name, imagePath, frameWidth, frameHeight, duration)
    if not self.animations[name] then
        local image = self:loadImage(name .. "_sheet", imagePath)
        self.animations[name] = newAnimation(image, frameWidth, frameHeight, duration)
    end
    return self.animations[name]
end

function ResourceManager:getAnimation(name)
    return self.animations[name]
end

function ResourceManager:loadAllAssets()
    -- Load fonts
    self:loadFont("fontXL", "assets/munro-small.ttf", 96)
    self:loadFont("fontL", "assets/munro-small.ttf", 36)
    self:loadFont("fontM", "assets/munro-small.ttf", 24)
    self:loadFont("fontS", "assets/munro-small.ttf", 18)
    self:loadFont("fontXS", "assets/munro-small.ttf", 15)
    
    -- Load images
    self:loadImage("background", "assets/background.png")
    self:loadImage("wizard", "assets/wizard.png")
    self:loadImage("placeholder", "assets/placeholder.png")

    self:loadCards()
end

function ResourceManager:createCard(cardIndex, cardLine)
    local inputTable = split(cardLine, " ")
    local card = {
        x = 0,
        y = 0,
        r = 0, -- rotation of card
        s = 1, -- scale of card
        t = 0, -- time
        name = string.lower(inputTable[1]),
        damage = tonumber(inputTable[2]),
        mana = tonumber(inputTable[3]),
        type = inputTable[4],
        elem = inputTable[5],
        index = cardIndex,
        deck = 0
    }
    
    -- Load card animation
    local cardImage = self:getImage("card_" .. card.name)
    if cardImage then
        card.anim = newAnimation(cardImage, 160, 160, 1)
    else
        local placeholderImage = self:getImage("placeholder")
        card.anim = newAnimation(placeholderImage, 160, 160, 10)
    end

    -- Where the card is animated (proj, other, self)
    card.loc = inputTable[6]

    local cardText = ""
    for i = 7, #inputTable do
        cardText = cardText .. " " .. inputTable[i]
    end
    card.text = string.lower(cardText)

    setmetatable(card, Card)
    return card
end

function ResourceManager:loadCards()
    local file = io.open("./cards.txt", "r")
    if not file then 
        error("Failed to open cards.txt - file not found")
    end
    
    local numCards = tonumber(file:read())
    
    -- Read all card data, load images, and create cards in one pass
    for i = 1, numCards do
        local line = file:read()
        if line then
            local cardName = split(line, " ")[1]
            local path = "assets/cards/" .. cardName .. ".png"
            local cardImageFile = io.open(path, "r")
            if cardImageFile then
                cardImageFile:close()
                self:loadImage("card_" .. cardName, path)
            end
            
            -- Create the card object
            cards[i] = self:createCard(i, line)
        end
    end
    file:close()
end

function ResourceManager:cleanup()
    -- Clean up resources if needed
    self.images = {}
    self.fonts = {}
    self.sounds = {}
    self.animations = {}
end