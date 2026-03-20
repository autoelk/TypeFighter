require "scenes.BaseScene"
local InputResult = require "enums.InputResult"
local SceneId = require "enums.SceneId"

local castFailureMessages = {
    [InputResult.CastCard.CardNotInHand] = "card not in hand",
    [InputResult.CastCard.InsufficientMana] = "insufficient mana",
    [InputResult.CastCard.InsufficientHealth] = "insufficient health",
    [InputResult.CastCard.CannotCast] = "cannot cast",
}

-- Game Scene (main gameplay), represents a single match between two players
GameScene = {}
setmetatable(GameScene, {
    __index = BaseScene
})
GameScene.__index = GameScene

local playerPositions = { {
    x = 250,
    y = 375,
    uiX = 25,
    textOffsetX = 30,
    libraryX = 10,
    deckX = 25,
    mirror = false
}, {
    x = GAME_WIDTH - 250 - SPRITE_SIZE,
    y = 375,
    uiX = GAME_WIDTH - 25,
    textOffsetX = -25,
    libraryX = GAME_WIDTH - MINI_CARD_WIDTH - 10,
    deckX = GAME_WIDTH - MINI_CARD_WIDTH - 25,
    mirror = true
} }

function GameScene:new(ctx)
    local scene = setmetatable(BaseScene:new(ctx), self)
    scene.name = SceneId.Game
    scene.controlsHint = "[q]uit to menu [esc] pause"
    scene.player1Controller = nil
    scene.player2Controller = nil
    scene.activeSpells = {}
    scene.gameOverTriggered = false
    return scene
end

function GameScene:setPlayer1(controller)
    self.player1Controller = controller
    self.player1Controller.x = playerPositions[1].x
    self.player1Controller.y = playerPositions[1].y
    self.player1Controller.uiX = playerPositions[1].uiX
    self.player1Controller.textOffsetX = playerPositions[1].textOffsetX
    self.player1Controller.libraryX = playerPositions[1].libraryX
    self.player1Controller.deckX = playerPositions[1].deckX
    self.player1Controller.mirror = playerPositions[1].mirror
    if self.player2Controller ~= nil then
        self.player1Controller:setOpponent(self.player2Controller)
        self.player2Controller:setOpponent(self.player1Controller)
    end
end

function GameScene:setPlayer2(controller)
    self.player2Controller = controller
    self.player2Controller.x = playerPositions[2].x
    self.player2Controller.y = playerPositions[2].y
    self.player2Controller.uiX = playerPositions[2].uiX
    self.player2Controller.textOffsetX = playerPositions[2].textOffsetX
    self.player2Controller.libraryX = playerPositions[2].libraryX
    self.player2Controller.deckX = playerPositions[2].deckX
    self.player2Controller.mirror = playerPositions[2].mirror
    if self.player1Controller ~= nil then
        self.player1Controller:setOpponent(self.player2Controller)
        self.player2Controller:setOpponent(self.player1Controller)
    end
end

function GameScene:enter()
    -- Initialize players for gameplay
    self.player1Controller:reset()
    self.player2Controller:reset()

    -- Apply starting effects, healing and mana regen
    -- TODO: Figure out a better way to hide these effects
    self.player1Controller.player:applyEffect(HealthRegenEffect:new("", self.player1Controller.player, nil, self.player1Controller.player.healthRegen))
    self.player1Controller.player:applyEffect(ManaRegenEffect:new("", self.player1Controller.player, nil, self.player1Controller.player.manaRegen))
    self.player2Controller.player:applyEffect(HealthRegenEffect:new("", self.player2Controller.player, nil, self.player2Controller.player.healthRegen))
    self.player2Controller.player:applyEffect(ManaRegenEffect:new("", self.player2Controller.player, nil, self.player2Controller.player.manaRegen))

    self.player1Controller.player.library = self.player1Controller.player.deck
    self.player2Controller.player.library = self.player2Controller.player.deck
    -- Draw starting hands
    for i = 1, STARTING_HAND_SIZE do
        self.player1Controller.player:drawCard()
        self.player2Controller.player:drawCard()
    end

    -- Set game interface messages
    self.ctx.ui.messageLeft = "type card names to cast them"
    self.ctx.ui.messageRight = self.controlsHint

    -- Initialize active spells list for this game
    self.activeSpells = {}
    self.gameOverTriggered = false
end

function GameScene:update(dt)
    self.player1Controller:update(dt)
    self.player2Controller:update(dt)

    for i = #self.activeSpells, 1, -1 do
        local spell = self.activeSpells[i]
        if spell.anim.timeLeft and spell.anim.timeLeft <= 0 then
            table.remove(self.activeSpells, i)
        else
            spell:update(dt)
        end
    end

    if not self.gameOverTriggered then
        local p1Dead = not self.player1Controller.player.isAlive
        local p2Dead = not self.player2Controller.player.isAlive
        if p1Dead then
            self.gameOverTriggered = true
            -- Player defeated: go to Game Over screen
            self.ctx.sceneManager:changeScene(SceneId.GameOver)
        elseif p2Dead then
            self.gameOverTriggered = true
            -- Opponent defeated: show stage end overlay
            self.ctx.sceneManager:pushScene(SceneId.StageEnd)
        end
    end
end

function GameScene:draw()
    self.player1Controller:draw()
    self.player2Controller:draw()

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
        self.ctx.sceneManager:pushScene(SceneId.Pause)
    end
end

function GameScene:handleInput(userInput)
    for _, playerController in ipairs({ self.player1Controller, self.player2Controller }) do
        if playerController.isHuman then
            local result = playerController:handleInput(userInput)
            if result == InputResult.Quit then
                self.ctx.sceneManager:changeScene(SceneId.Menu)
            elseif result == InputResult.DrawFail then
                self.ctx.ui.messageLeft = "hand full, can't draw"
            elseif result == InputResult.DrawSuccess then
                self.ctx.ui.messageLeft = "drew a card"
            elseif result == InputResult.CastCard.Success then
                self.ctx.ui.messageLeft = "cast " .. userInput
            elseif castFailureMessages[result] then
                self.ctx.ui.messageLeft = "cannot cast " .. userInput .. ": " .. castFailureMessages[result]
            elseif result == InputResult.Unknown then
                self.ctx.ui.messageLeft = "unknown command: " .. userInput
            end
        end
    end
end
