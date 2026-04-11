require "constants"
require "app.Context"

local SceneId = require "enums.SceneId"
local Sound = require "util.Sound"
local push = require "libraries.push"

require "players.BasePlayer"
require "players.BasePlayerController"
require "players.HumanPlayerController"
require "players.AIPlayerController"

require "SceneManager"
require "CardManager"
require "CharacterManager"
require "ResourceManager"
require "RunState"

require "scenes.BaseScene"
require "scenes.MenuScene"
require "scenes.CardBrowseScene"
require "scenes.CharacterSelectScene"
require "scenes.BattleScene"
require "scenes.PauseScene"
require "scenes.GameOverScene"
require "scenes.BattleEndScene"

function love.load()
    lg = love.graphics
    lg.setDefaultFilter("nearest", "nearest")

    push:setupScreen(GAME_WIDTH, GAME_HEIGHT, GAME_WIDTH, GAME_HEIGHT, {
        fullscreen = true,
        resizable = false,
        pixelperfect = true,
        highdpi = true,
        canvas = true,
    })
    push:setBorderColor(COLORS.BLACK)

    math.randomseed(os.time())
    love.keyboard.setKeyRepeat(true)

    -- Initialize context
    ctx = Context:new()

    -- Initialize resources
    ctx.resourceManager:loadAllAssets(ctx.cardManager:getAllCardNames())

    -- Cache fonts/images in context (removes need for global `font*` and `background`)
    ctx.fonts.fontXL = ctx.resourceManager:getFont("fontXL")
    ctx.fonts.fontL = ctx.resourceManager:getFont("fontL")
    ctx.fonts.fontM = ctx.resourceManager:getFont("fontM")
    ctx.fonts.fontS = ctx.resourceManager:getFont("fontS")
    ctx.assets.background = ctx.resourceManager:getImage("background")

    -- Initialize cards for selection
    for _, cardName in ipairs(ctx.cardManager:getAllCardNames()) do
        local tempCard = ctx.cardManager.cardTypes[cardName]:new(ctx, 0, 0)
        ctx.cardManager.cardCharacters[cardName] = tempCard.character
    end

    -- Initialize scenes
    ctx.sceneManager:addScene(MenuScene:new(ctx))
    ctx.sceneManager:addScene(CardBrowseScene:new(ctx))
    ctx.sceneManager:addScene(CharacterSelectScene:new(ctx))
    ctx.sceneManager:addScene(BattleScene:new(ctx))
    ctx.sceneManager:addScene(PauseScene:new(ctx))
    ctx.sceneManager:addScene(GameOverScene:new(ctx))
    ctx.sceneManager:addScene(BattleEndScene:new(ctx))

    ctx.sceneManager:changeScene(SceneId.Menu)
    
    local backgroundMusic = ctx.resourceManager:getSound("music")
    backgroundMusic:setLooping(true)
    backgroundMusic:setVolume(0.5)
    backgroundMusic:play()
end

function love.keypressed(key)
    ctx.sceneManager:keypressed(key)
end

function love.update(dt)
    ctx.sceneManager:update(dt)
end

function love.draw()
    push:apply("start")
    lg.clear(COLORS.BLACK)

    -- Background
    local saturationShader = ctx.resourceManager:getShader("saturation")
    lg.setShader(saturationShader)
    saturationShader:send("saturation", 0.75)
    lg.draw(ctx.assets.background, 0, 0, 0, PIXEL_TO_GAME_SCALE, PIXEL_TO_GAME_SCALE)
    lg.setShader()
    lg.setColor({ 0, 0, 0, 0.25 })
    lg.rectangle("fill", 0, 0, GAME_WIDTH, GAME_HEIGHT)

    -- Draw current scene
    ctx.sceneManager:draw()

    push:apply("end")
end

function love.resize(w, h)
    push:resize(w, h)
end

function love.textinput(t)
    ctx.sceneManager:textinput(t)
end

function love.wheelmoved(dx, dy)
    ctx.sceneManager:wheelmoved(dx, dy)
end
