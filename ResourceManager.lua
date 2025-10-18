-- Manages loading and accessing game resources like images, fonts, sounds, and animations.
ResourceManager = {}
ResourceManager.__index = ResourceManager

function ResourceManager:new()
    local manager = {
        images = {},
        fonts = {},
        sounds = {},
        animations = {},
        dict = {}
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

function ResourceManager:loadAllAssets()
    -- Load fonts
    self:loadFont("fontXL", "assets/munro-small.ttf", 96)
    self:loadFont("fontL", "assets/munro-small.ttf", 36)
    self:loadFont("fontM", "assets/munro-small.ttf", 24)
    self:loadFont("fontS", "assets/munro-small.ttf", 18)
    self:loadFont("fontXS", "assets/munro-small.ttf", 15)

    -- Load images
    self:loadImage("background", "assets/background.png")

    self:loadImage("wizardIdle", "assets/wizardIdle.png")
    self:loadImage("wizardDeath", "assets/wizardDeath.png")
    self:loadImage("wizardCast", "assets/wizardCast.png")
    self:loadImage("evilWizardIdle", "assets/evilWizardIdle.png")
    self:loadImage("evilWizardDeath", "assets/evilWizardDeath.png")
    self:loadImage("evilWizardCast", "assets/evilWizardCast.png")

    self:loadImage("placeholder", "assets/placeholder.png")

    -- Load all card images
    local cardNames = cardManager:getAllCardNames()
    for i, cardName in ipairs(cardNames) do
        local path = "assets/cards/" .. cardName .. ".png"
        local cardImageFile = io.open(path, "r")
        if cardImageFile then
            cardImageFile:close()
            self:loadImage("card_" .. cardName, path)
        end
        if not self:getImage("card_" .. cardName) then
            self.images["card_" .. cardName] = self:getImage("placeholder")
        end
    end

    self:loadDictionary()
end

function ResourceManager:newAnimation(imageName, width, height)
    local animation = {}
    animation.spriteSheet = self.images[imageName]
    animation.quads = {}

    width = width or SPRITE_PIXEL_SIZE
    height = height or SPRITE_PIXEL_SIZE

    for y = 0, animation.spriteSheet:getHeight() - height, height do
        for x = 0, animation.spriteSheet:getWidth() - width, width do
            table.insert(animation.quads, lg.newQuad(x, y, width, height, animation.spriteSheet:getDimensions()))
        end
    end

    local fps = 12
    animation.frameDuration = 1 / fps
    animation.currentFrame = 1
    animation.accumulator = 0
    animation.timeLeft = nil
    animation.playMode = nil -- loop | once | loop_for

    -- transformations
    animation.rotation = 0
    animation.scaleX = PIXEL_TO_GAME_SCALE
    animation.scaleY = PIXEL_TO_GAME_SCALE
    animation.offsetX = 0
    animation.offsetY = 0

    return animation
end

function ResourceManager:loadDictionary()
    local file = io.open("assets/dict.txt", "r")
    if not file then
        error("Could not open dictionary file.")
    end

    self.dict = {}
    for line in file:lines() do
        local word = line:match("^%s*(.-)%s*$") -- trim whitespace
        if word ~= "" then
            table.insert(self.dict, word)
        end
    end
    file:close()
end

function ResourceManager:getRandomWord()
    local index = math.random(#self.dict)
    return self.dict[index]
end
