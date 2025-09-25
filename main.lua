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
input = "" -- player input
message = "" -- left side text
message2 = "" -- right side text

-- Colors
colors = {
    red = {250/255, 89/255, 52/255},
    orange = {250/255, 121/255, 33/255},
    yellow = {253/255, 231/255, 76/255},
    green = {155/255, 197/255, 61/255},
    blue = {91/255, 192/255, 235/255},
    grey = {77/255, 80/255, 87/255},
    white = {1, 1, 1},
    black = {0, 0, 0}
}

function love.load()
    lg = love.graphics
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
    deck = gameManager:getDeck()
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
    
    -- Update card animations
    for i = 1, #cards do
        cards[i].t = cards[i].t - dt
        if cards[i].t < 0 then
            cards[i].t = 0
        end
        cards[i].anim.currentTime = cards[i].anim.currentTime + dt
        if cards[i].anim.currentTime >= cards[i].anim.duration then
            cards[i].anim.currentTime = cards[i].anim.currentTime - cards[i].anim.duration
        end
    end

    -- Update player death animations
    local player1 = gameManager:getPlayer(1)
    local player2 = gameManager:getPlayer(2)
    if player1 and player1.health <= 0 then
        player1.anim.currentTime = player1.anim.currentTime + dt
        if player1.anim.currentTime >= player1.anim.duration then
            player1.anim.currentTime = player1.anim.currentTime - player1.anim.duration
        end
    end
    if player2 and player2.health <= 0 then
        player2.anim.currentTime = player2.anim.currentTime + dt
        if player2.anim.currentTime >= player2.anim.duration then
            player2.anim.currentTime = player2.anim.currentTime - player2.anim.duration
        end
    end

    -- Update current state
    stateManager:update(dt)
end

function love.draw()
    -- Setup and background
    local scale = math.min(lg.getWidth() / 800, lg.getHeight() / 600)
    lg.scale(scale, scale)
    lg.draw(background, 0, 0)
    lg.setFont(fontM)
    
    -- Draw players
    local player1 = gameManager:getPlayer(1)
    local player2 = gameManager:getPlayer(2)
    if player1 then
        lg.setColor(colors.white)
        player1:Draw()
    end
    if player2 then
        lg.setColor(colors.red)
        player2:Draw()
    end
    lg.setColor(colors.white)

    -- Draw current state
    stateManager:draw()

    -- Draw input interface
    lg.setColor(colors.black)
    lg.rectangle("fill", 0, 570, 800, 30)
    lg.setFont(fontM)
    lg.setColor(colors.white)
    lg.printf(message, 5, 570, 800, "left")
    lg.printf(message2, -5, 570, 800, "right")
    lg.printf(input, 5, 570, 800, "left")
end

function love.textinput(t)
    input = input .. t
    message = "" -- Clear message when user starts typing
end

function love.wheelmoved(dx, dy)
    stateManager:wheelmoved(dx, dy)
end