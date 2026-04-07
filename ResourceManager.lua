-- Manages loading and accessing game resources like images, fonts, sounds, and animations.
ResourceManager = {}
ResourceManager.__index = ResourceManager

function ResourceManager:new()
    local manager = {
        shaders = {},
        images = {},
        fonts = {},
        sounds = {},
        animations = {},
        dict = {}
    }
    setmetatable(manager, self)
    return manager
end

function ResourceManager:loadShader(name, code)
    if not self.shaders[name] then
        self.shaders[name] = love.graphics.newShader(code)
    end
    return self.shaders[name]
end

function ResourceManager:getShader(name)
    return self.shaders[name]
end

function ResourceManager:loadFont(name, path, size)
    if not self.fonts[name] then
        self.fonts[name] = love.graphics.newFont(path, size, "mono")
        self.fonts[name]:setLineHeight(0.75)
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

function ResourceManager:loadSound(name, path)
    if not self.sounds[name] then
        self.sounds[name] = love.audio.newSource(path, "static")
    end
    return self.sounds[name]
end

function ResourceManager:getSound(name)
    return self.sounds[name]
end

function ResourceManager:loadAllAssets(cardNames)
    if not cardNames then
        error("ResourceManager:loadAllAssets(cardNames) requires cardNames")
    end
    -- Load fonts
    self:loadFont("fontXL", "assets/fonts/Habbo.ttf", 96)
    self:loadFont("fontL", "assets/fonts/Habbo.ttf", 48)
    self:loadFont("fontM", "assets/fonts/Habbo.ttf", 32)
    self:loadFont("fontS", "assets/fonts/Habbo.ttf", 16)

    -- Load images
    self:loadImage("background", "assets/background.png")

    self:loadImage("wizardIdle", "assets/characters/wizard/wizardIdle.png")
    self:loadImage("wizardCast", "assets/characters/wizard/wizardCast.png")
    self:loadImage("wizardDeath", "assets/characters/wizard/wizardDeath.png")

    self:loadImage("vampireIdle", "assets/characters/vampire/vampireIdle.png")
    self:loadImage("vampireCast", "assets/characters/vampire/vampireCast.png")
    self:loadImage("vampireDeath", "assets/characters/vampire/vampireDeath.png")

    self:loadImage("placeholder", "assets/placeholder.png")

    -- Load all card images
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

    -- Load sounds
    self:loadSound("hurt", "assets/sounds/hurt.wav")

    -- 0.0 is grayscale, 1.0 is full color
    self:loadShader("saturation", [[
        extern float saturation;
        vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords) {
            vec4 pixel = Texel(texture, texture_coords);
            float gray = dot(pixel.rgb, vec3(0.299, 0.587, 0.114));
            vec3 grayscale = vec3(gray);
            return vec4(mix(grayscale, pixel.rgb, saturation), pixel.a) * color;
        }
    ]])

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

function ResourceManager:getRandomWords(count)
    local words = {}
    for i = 1, count do
        local index = math.random(#self.dict)
        table.insert(words, self.dict[index])
    end
    return words
end
