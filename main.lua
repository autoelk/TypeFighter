local utf8 = require("utf8")
require "players.BasePlayer"
require "players.HumanPlayer"
require "players.AIPlayer"

require "SceneManager"
require "CardManager"
require "ResourceManager"

require "scenes.BaseScene"
require "scenes.MenuScene"
require "scenes.CardBrowseScene"
require "scenes.InstructionsScene"
require "scenes.CardSelectScene"
require "scenes.GameScene"
require "scenes.PauseScene"
require "scenes.GameOverScene"

-- Global game state
gameTime = 0
sceneManager = nil
cardManager = nil
resourceManager = nil
input = ""    -- player input
message = ""  -- left side text
message2 = "" -- right side text
activeSpells = {}

-- Colors
COLORS = {
    RED = { 250 / 255, 89 / 255, 52 / 255 },
    ORANGE = { 250 / 255, 121 / 255, 33 / 255 },
    YELLOW = { 253 / 255, 231 / 255, 76 / 255 },
    GREEN = { 155 / 255, 197 / 255, 61 / 255 },
    BLUE = { 91 / 255, 192 / 255, 235 / 255 },
    GREY = { 77 / 255, 80 / 255, 87 / 255 },
    WHITE = { 1, 1, 1 },
    BLACK = { 0, 0, 0 }
}

-- UI constants
GAME_WIDTH = 1280
GAME_HEIGHT = 720
PIXEL_TO_GAME_SCALE = 5
SCROLL_SPEED = 75

-- Sprite constants
SPRITE_PIXEL_SIZE = 32
SPRITE_SIZE = SPRITE_PIXEL_SIZE * PIXEL_TO_GAME_SCALE

-- Card dimensions
LARGE_CARD_WIDTH = SPRITE_SIZE + 20
LARGE_CARD_HEIGHT = SPRITE_SIZE + 100
MINI_CARD_WIDTH = SPRITE_SIZE
MINI_CARD_HEIGHT = 60

-- Game constants
MAX_DECK_SIZE = 5
MAX_HAND_SIZE = 5
STARTING_HAND_SIZE = 3

function love.load()
    lg = love.graphics
    lg.setDefaultFilter("nearest", "nearest")

    math.randomseed(os.time())
    love.keyboard.setKeyRepeat(true)

    sceneManager = SceneManager:new()
    cardManager = CardManager:new()
    resourceManager = ResourceManager:new()
    resourceManager:loadAllAssets()

    fontXL = resourceManager:getFont("fontXL")
    fontL = resourceManager:getFont("fontL")
    fontM = resourceManager:getFont("fontM")
    fontS = resourceManager:getFont("fontS")
    fontXS = resourceManager:getFont("fontXS")
    background = resourceManager:getImage("background")

    -- TODO: Create a better solution for storing players
    HUMANPLAYER = HumanPlayer:new(1)
    AIPLAYER = AIPlayer:new(2, "normal")

    sceneManager:addScene(MenuScene:new())
    sceneManager:addScene(CardBrowseScene:new())
    sceneManager:addScene(InstructionsScene:new())
    sceneManager:addScene(CardSelectScene:new())
    sceneManager:addScene(GameScene:new())
    sceneManager:addScene(PauseScene:new())
    sceneManager:addScene(GameOverScene:new())

    sceneManager:changeScene("menu")
end

function love.keypressed(key)
    if key == "backspace" and utf8.offset(input, -1) then
        input = string.sub(input, 1, utf8.offset(input, -1) - 1)
        return
    end
    sceneManager:keypressed(key)
end

function love.update(dt)
    gameTime = gameTime + dt
    HUMANPLAYER:update(dt)
    AIPLAYER:update(dt)

    -- Update current scene
    sceneManager:update(dt)
end

function love.draw()
    lg.clear(COLORS.WHITE)
    lg.setColor(COLORS.WHITE)
    -- Setup
    local scale = math.min(lg.getWidth() / GAME_WIDTH, lg.getHeight() / GAME_HEIGHT)
    lg.translate((lg.getWidth() - GAME_WIDTH * scale) / 2, (lg.getHeight() - GAME_HEIGHT * scale) / 2)
    lg.scale(scale, scale)

    -- Background
    lg.draw(background, 0, 0, 0, PIXEL_TO_GAME_SCALE, PIXEL_TO_GAME_SCALE)
    lg.setFont(fontM)

    -- Draw players
    HUMANPLAYER:draw()
    AIPLAYER:draw()

    -- Draw current scene
    sceneManager:draw()

    -- Draw input interface
    local inputRectHeight = 30
    lg.setColor(COLORS.BLACK)
    lg.rectangle("fill", 0, GAME_HEIGHT - inputRectHeight, GAME_WIDTH, inputRectHeight)
    lg.setFont(fontM)
    lg.setColor(COLORS.WHITE)
    lg.printf(message, 5, GAME_HEIGHT - inputRectHeight, GAME_WIDTH, "left")
    lg.printf(message2, -5, GAME_HEIGHT - inputRectHeight, GAME_WIDTH, "right")
    lg.printf(input, 5, GAME_HEIGHT - inputRectHeight, GAME_WIDTH, "left")
end

function love.textinput(t)
    input = input .. t
    message = "" -- Clear message when user starts typing
end

function love.wheelmoved(dx, dy)
    sceneManager:wheelmoved(dx, dy)
end
