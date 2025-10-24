require "constants"
require "players.BasePlayer"
require "players.BasePlayerController"
require "players.HumanPlayerController"
require "players.AIPlayerController"

require "SceneManager"
require "CardManager"
require "CharacterManager"
require "ResourceManager"

require "scenes.BaseScene"
require "scenes.MenuScene"
require "scenes.CardBrowseScene"
require "scenes.CharacterSelectScene"
require "scenes.GameScene"
require "scenes.PauseScene"
require "scenes.GameOverScene"
require "scenes.InstructionsScene"

-- Global game state
sceneManager = nil
cardManager = nil
characterManager = nil
resourceManager = nil

input = ""        -- player input
messageLeft = ""  -- left side text
messageRight = "" -- right side text

function love.load()
    lg = love.graphics
    lg.setDefaultFilter("nearest", "nearest")

    math.randomseed(os.time())
    love.keyboard.setKeyRepeat(true)

    sceneManager = SceneManager:new()
    cardManager = CardManager:new()
    characterManager = CharacterManager:new()
    resourceManager = ResourceManager:new()
    resourceManager:loadAllAssets()

    fontXL = resourceManager:getFont("fontXL")
    fontL = resourceManager:getFont("fontL")
    fontM = resourceManager:getFont("fontM")
    fontS = resourceManager:getFont("fontS")
    fontXS = resourceManager:getFont("fontXS")
    background = resourceManager:getImage("background")

    sceneManager:addScene(MenuScene:new())
    sceneManager:addScene(CardBrowseScene:new())
    sceneManager:addScene(CharacterSelectScene:new())
    sceneManager:addScene(GameScene:new())
    sceneManager:addScene(PauseScene:new())
    sceneManager:addScene(GameOverScene:new())
    sceneManager:addScene(InstructionsScene:new())

    sceneManager:changeScene("menu")
end

function love.keypressed(key)
    sceneManager:keypressed(key)
end

function love.update(dt)
    sceneManager:update(dt)
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
    lg.draw(background, 0, 0, 0, PIXEL_TO_GAME_SCALE, PIXEL_TO_GAME_SCALE)
    lg.setFont(fontM)

    -- Draw current scene
    sceneManager:draw()

    -- Draw input interface
    local inputRectHeight = 30
    lg.setColor(COLORS.BLACK)
    lg.rectangle("fill", 0, -offsetY, GAME_WIDTH, offsetY)
    lg.rectangle("fill", 0, GAME_HEIGHT - inputRectHeight, GAME_WIDTH, inputRectHeight + offsetY)
    lg.setFont(fontM)
    lg.setColor(COLORS.WHITE)
    lg.printf(messageLeft, 5, GAME_HEIGHT - inputRectHeight, GAME_WIDTH, "left")
    lg.printf(messageRight, -5, GAME_HEIGHT - inputRectHeight, GAME_WIDTH, "right")
    lg.printf(input, 5, GAME_HEIGHT - inputRectHeight, GAME_WIDTH, "left")
end

function love.textinput(t)
    input = input .. t
    messageLeft = "" -- Clear message when user starts typing
end

function love.wheelmoved(dx, dy)
    sceneManager:wheelmoved(dx, dy)
end
