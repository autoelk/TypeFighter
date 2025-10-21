require "scenes.BaseScene"
local InputResult = require "enums.InputResult"

-- Game Scene (main gameplay)
GameScene = {}
setmetatable(GameScene, {
    __index = BaseScene
})
GameScene.__index = GameScene

function GameScene:new()
    local scene = setmetatable(BaseScene:new(), self)
    scene.name = "game"
    scene.controlsHint = "[q]uit to menu [esc] pause"
    return scene
end

function GameScene:enter()
    -- Initialize players for gameplay
    HUMANPLAYERCONTROLLER:reset()
    AIPLAYERCONTROLLER:reset()

    HUMANPLAYERCONTROLLER.player.library = HUMANPLAYERCONTROLLER.player.deck
    AIPLAYERCONTROLLER.player.library = AIPLAYERCONTROLLER.player.deck

    -- Draw starting hands
    for i = 1, STARTING_HAND_SIZE do
        HUMANPLAYERCONTROLLER.player:drawCard()
        AIPLAYERCONTROLLER.player:drawCard()
    end

    -- Set game interface messages
    messageLeft = "type card names to cast them"
    messageRight = self.controlsHint

    -- Initialize active spells list for this game
    self.activeSpells = {}
end

function GameScene:update(dt)
    HUMANPLAYERCONTROLLER:update(dt)
    AIPLAYERCONTROLLER:update(dt)

    for i = #self.activeSpells, 1, -1 do
        local spell = self.activeSpells[i]
        if spell.anim.timeLeft and spell.anim.timeLeft <= 0 then
            table.remove(self.activeSpells, i)
        else
            spell:update(dt)
        end
    end

    if not HUMANPLAYERCONTROLLER.player.isAlive or not AIPLAYERCONTROLLER.player.isAlive then
        self.sceneManager:changeScene("gameOver")
    end
end

function GameScene:draw()
    HUMANPLAYERCONTROLLER:draw()
    AIPLAYERCONTROLLER:draw()

    -- Draw active spells
    if self.activeSpells then
        for i = 1, #self.activeSpells do
            local s = self.activeSpells[i]
            s:draw()
        end
    end
end

function GameScene:keypressed(key)
    if key == "escape" then
        self.sceneManager:pushScene("pause")
    elseif key == "return" then
        local userInput = self:processInput()
        local result = HUMANPLAYERCONTROLLER:handleInput(userInput)
        if result == InputResult.Quit then
            self.sceneManager:changeScene("menu")
        elseif result == InputResult.DrawFail then
            messageLeft = "hand full, can't draw"
        elseif result == InputResult.DrawSuccess then
            messageLeft = "drew a card"
        elseif result == InputResult.CastCard.Success then
            messageLeft = "cast " .. userInput
        elseif result == InputResult.CastCard.CardNotInHand then
            messageLeft = "cannot cast " .. userInput .. ": card not in hand"
        elseif result == InputResult.CastCard.InsufficientMana then
            messageLeft = "cannot cast " .. userInput .. ": insufficient mana"
        elseif result == InputResult.CastCard.CannotCast then
            messageLeft = "cannot cast " .. userInput
        elseif result == InputResult.Unknown then
            messageLeft = "unknown command: " .. userInput
        end
        input = "" -- clear user input field
    end
end
