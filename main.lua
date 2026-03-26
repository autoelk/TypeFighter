require "constants"
require "app.Context"

local SceneId = require "enums.SceneId"
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
require "scenes.GameScene"
require "scenes.PauseScene"
require "scenes.GameOverScene"
require "scenes.InstructionsScene"
require "scenes.StageEndScene"

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

    -- Initialize scenes
    ctx.sceneManager:addScene(MenuScene:new(ctx))
    ctx.sceneManager:addScene(CardBrowseScene:new(ctx))
    ctx.sceneManager:addScene(CharacterSelectScene:new(ctx))
    ctx.sceneManager:addScene(GameScene:new(ctx))
    ctx.sceneManager:addScene(PauseScene:new(ctx))
    ctx.sceneManager:addScene(GameOverScene:new(ctx))
    ctx.sceneManager:addScene(InstructionsScene:new(ctx))
    ctx.sceneManager:addScene(StageEndScene:new(ctx))

    ctx.sceneManager:changeScene(SceneId.Menu)
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
    lg.draw(ctx.assets.background, 0, 0, 0, PIXEL_TO_GAME_SCALE, PIXEL_TO_GAME_SCALE)
    lg.setFont(ctx.fonts.fontM)

    -- Draw current scene
    ctx.sceneManager:draw()

    push:apply("end")
end

function love.resize(w, h)
    push:resize(w, h)
end

function love.textinput(t)
    ctx.ui.input = ctx.ui.input .. t
    ctx.ui.messageLeft = "" -- Clear message when user starts typing
end

function love.wheelmoved(dx, dy)
    ctx.sceneManager:wheelmoved(dx, dy)
end
