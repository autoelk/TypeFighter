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
        self.fonts[name] = love.graphics.newFont(path, size, "mono")
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
        self.animations[name] = self:newAnimation(image, frameWidth, frameHeight, duration)
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

function ResourceManager:loadCards()
    -- Get all available card names from the CardFactory
    local cardNames = cardFactory:getAllCardNames()

    -- Create cards directly using CardFactory
    for i, cardName in ipairs(cardNames) do
        -- Load card image
        local path = "assets/cards/" .. cardName .. ".png"
        local cardImageFile = io.open(path, "r")
        if cardImageFile then
            cardImageFile:close()
            self:loadImage("card_" .. cardName, path)
        end

        -- Create basic card data structure
        local cardData = {
            x = 0,
            y = 0,
            index = i,
            name = cardName,
            loc = "hand" -- default location
        }

        -- Create animation for the card
        local cardImage = self:getImage("card_" .. cardName)
        if cardImage then
            cardData.anim = self:newAnimation(cardImage, 32, 32, 1)
        else
            local placeholderImage = self:getImage("placeholder")
            cardData.anim = self:newAnimation(placeholderImage, 32, 32, 10)
        end

        -- Use CardFactory to create the appropriate card class
        local card = cardFactory:createCard(cardName, cardData)
        gameManager:setCard(i, card)
    end
end

function ResourceManager:cleanup()
    -- Clean up resources if needed
    self.images = {}
    self.fonts = {}
    self.sounds = {}
    self.animations = {}
end

function ResourceManager:newAnimation(image, width, height, duration)
    local animation = {}
    animation.spriteSheet = image
    animation.quads = {}

    for y = 0, image:getHeight() - height, height do
        for x = 0, image:getWidth() - width, width do
            table.insert(animation.quads, lg.newQuad(x, y, width, height, image:getDimensions()))
        end
    end

    -- Fixed 12 FPS animation system
    animation.fps = 12
    animation.frameDuration = 1 / animation.fps
    animation.currentFrame = 1
    animation.accumulator = 0
    animation.loopMode = "loop"
    animation.loopTime = nil
    animation.elapsed = 0

    return animation
end

function ResourceManager:split(pString, pPattern)
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
