require "constants"
require "app.Context"
local SceneId = require "enums.SceneId"
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
    ctx.fonts.fontXS = ctx.resourceManager:getFont("fontXS")
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
    lg.clear(COLORS.BLACK)
    -- Setup
    local scale = math.min(lg.getWidth() / GAME_WIDTH, lg.getHeight() / GAME_HEIGHT)
    local offsetX = (lg.getWidth() - GAME_WIDTH * scale) / 2
    local offsetY = (lg.getHeight() - GAME_HEIGHT * scale) / 2
    lg.translate(offsetX, offsetY)
    lg.scale(scale, scale)

    -- Background
    lg.draw(ctx.assets.background, 0, 0, 0, PIXEL_TO_GAME_SCALE, PIXEL_TO_GAME_SCALE)
    lg.setFont(ctx.fonts.fontM)

    -- Draw current scene
    ctx.sceneManager:draw()

    -- Draw input interface
    local inputRectHeight = 30
    lg.setColor(COLORS.BLACK)
    lg.rectangle("fill", 0, -offsetY, GAME_WIDTH, offsetY)
    lg.rectangle("fill", 0, GAME_HEIGHT - inputRectHeight, GAME_WIDTH, inputRectHeight + offsetY)
    lg.setFont(ctx.fonts.fontM)
    lg.setColor(COLORS.WHITE)
    local ui = ctx.ui
    lg.printf(ui.messageLeft, 5, GAME_HEIGHT - inputRectHeight, GAME_WIDTH, "left")
    lg.printf(ui.messageRight, -5, GAME_HEIGHT - inputRectHeight, GAME_WIDTH, "right")
    lg.printf(ui.input, 5, GAME_HEIGHT - inputRectHeight, GAME_WIDTH, "left")
end

function love.textinput(t)
    ctx.ui.input = ctx.ui.input .. t
    ctx.ui.messageLeft = "" -- Clear message when user starts typing
end

function love.wheelmoved(dx, dy)
    ctx.sceneManager:wheelmoved(dx, dy)
end
