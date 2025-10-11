local utf8 = require("utf8")
require "cards.CardFactory"
require "players.BasePlayer"
require "players.HumanPlayer"
require "players.AIPlayer"
require "GameManager"
require "ResourceManager"
require "GameStateManager"
require "states.BaseState"
require "states.MenuState"
require "states.CardBrowseState"
require "states.InstructionsState"
require "states.CardSelectState"
require "states.GameState"
require "states.PauseState"
require "states.GameOverState"

-- Global game state
gameTime = 0
stateManager = nil
resourceManager = nil
input = ""    -- player input
message = ""  -- left side text
message2 = "" -- right side text

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
MAX_HAND_SIZE = 3

function love.load()
    lg = love.graphics
    lg.setDefaultFilter("nearest", "nearest")

    math.randomseed(os.time())
    love.keyboard.setKeyRepeat(true)

    stateManager = GameStateManager:new()
    resourceManager = ResourceManager:new()
    resourceManager:loadAllAssets()

    fontXL = resourceManager:getFont("fontXL")
    fontL = resourceManager:getFont("fontL")
    fontM = resourceManager:getFont("fontM")
    fontS = resourceManager:getFont("fontS")
    fontXS = resourceManager:getFont("fontXS")
    background = resourceManager:getImage("background")

    cards = gameManager:getCards()
    gameManager:addPlayer(HumanPlayer:new(1))
    gameManager:addPlayer(AIPlayer:new(2, "normal"))

    initializeStates()
    stateManager:changeState("menu")
end

function initializeStates()
    stateManager:addState("menu", MenuState:new())
    stateManager:addState("cardBrowse", CardBrowseState:new())
    stateManager:addState("instructions", InstructionsState:new())
    stateManager:addState("cardSelect", CardSelectState:new())
    stateManager:addState("game", GameState:new())
    stateManager:addState("pause", PauseState:new())
    stateManager:addState("gameOver", GameOverState:new())
end

function love.keypressed(key)
    if key == "backspace" and utf8.offset(input, -1) then
        input = string.sub(input, 1, utf8.offset(input, -1) - 1)
        return
    end
    stateManager:keypressed(key)
end

function love.update(dt)
    gameTime = gameTime + dt
    for i = 1, #cards do
        cards[i]:update(dt)
    end

    local humanPlayer = gameManager:getHumanPlayer()
    local aiPlayer = gameManager:getAIPlayer()
    humanPlayer:update(dt)
    aiPlayer:update(dt)

    -- Update current state
    stateManager:update(dt)
end

function love.draw()
    -- Setup
    local scale = math.min(lg.getWidth() / GAME_WIDTH, lg.getHeight() / GAME_HEIGHT)
    lg.translate((lg.getWidth() - GAME_WIDTH * scale) / 2, (lg.getHeight() - GAME_HEIGHT * scale) / 2)
    lg.scale(scale, scale)

    -- Background
    lg.draw(background, 0, 0, 0, PIXEL_TO_GAME_SCALE, PIXEL_TO_GAME_SCALE)
    lg.setFont(fontM)

    -- Draw players
    local humanPlayer = gameManager:getHumanPlayer()
    local aiPlayer = gameManager:getAIPlayer()
    lg.setColor(COLORS.WHITE)
    humanPlayer:draw()
    lg.setColor(COLORS.RED)
    aiPlayer:draw()
    lg.setColor(COLORS.WHITE)

    -- Draw current state
    stateManager:draw()

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
    stateManager:wheelmoved(dx, dy)
end
