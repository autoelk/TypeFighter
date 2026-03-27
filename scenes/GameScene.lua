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

function GameScene:new(ctx)
    local scene = setmetatable(BaseScene:new(ctx), self)
    scene.name = SceneId.Game
    scene.controlsHint = "[quit] to menu, [pause]"
    scene:addAvailableCommand("quit", true)
    scene:addAvailableCommand("pause", true)
    scene.humanController = nil
    scene.enemyController = nil
    scene.activeSpells = {}
    scene.gameOverTriggered = false
    return scene
end

function GameScene:setHumanController(controller)
    self.humanController = controller
    local renderer = self.humanController.renderer
    renderer.x = 256
    renderer.uiX = 16
    renderer.textOffsetX = 20
    renderer.libraryX = 16
    renderer.deckX = 16
    renderer.mirror = false
    if self.enemyController ~= nil then
        self.humanController:setOpponent(self.enemyController)
        self.enemyController:setOpponent(self.humanController)
    end
end

function GameScene:setEnemyController(controller)
    self.enemyController = controller
    local renderer = self.enemyController.renderer
    renderer.x = GAME_WIDTH - 256 - SPRITE_SIZE
    renderer.uiX = GAME_WIDTH - 16
    renderer.textOffsetX = -16
    renderer.libraryX = GAME_WIDTH - MINI_CARD_WIDTH - 16
    renderer.deckX = GAME_WIDTH - MINI_CARD_WIDTH - 16
    renderer.mirror = true
    if self.humanController ~= nil then
        self.humanController:setOpponent(self.enemyController)
        self.enemyController:setOpponent(self.humanController)
    end
end

function GameScene:enter()
    -- Initialize players for gameplay
    self.humanController:reset()
    self.enemyController:reset()

    -- Apply starting effects, healing and mana regen
    -- TODO: Figure out a better way to hide these effects
    self.humanController.player:applyEffect(HealthRegenEffect:new("", self.humanController.player, nil, self.humanController.player.healthRegen))
    self.humanController.player:applyEffect(ManaRegenEffect:new("", self.humanController.player, nil, self.humanController.player.manaRegen))
    self.enemyController.player:applyEffect(HealthRegenEffect:new("", self.enemyController.player, nil, self.enemyController.player.healthRegen))
    self.enemyController.player:applyEffect(ManaRegenEffect:new("", self.enemyController.player, nil, self.enemyController.player.manaRegen))

    self.humanController.player.library = self.humanController.player.deck
    self.enemyController.player.library = self.enemyController.player.deck
    -- Draw starting hands
    for i = 1, STARTING_HAND_SIZE do
        self.humanController.player:drawCard()
        self.enemyController.player:drawCard()
    end

    -- Set game interface messages
    self.ctx.ui.input = ""
    self.ctx.ui.messageLeft = "type card name, then type the incantation to cast"
    self.ctx.ui.messageRight = self.controlsHint

    -- Initialize active spells list for this game
    self.activeSpells = {}
    self.gameOverTriggered = false
    self:refreshAvailableCommands()
end

function GameScene:update(dt)
    self.humanController:update(dt)
    self.enemyController:update(dt)

    for i = #self.activeSpells, 1, -1 do
        local spell = self.activeSpells[i]
        if spell.anim.timeLeft and spell.anim.timeLeft <= 0 then
            table.remove(self.activeSpells, i)
        else
            spell:update(dt)
        end
    end

    if not self.gameOverTriggered then
        if not self.humanController.player.isAlive then
            self.gameOverTriggered = true
            self.ctx.sceneManager:changeScene(SceneId.GameOver)
        elseif not self.enemyController.player.isAlive then
            self.gameOverTriggered = true
            self.ctx.sceneManager:pushScene(SceneId.StageEnd)
        end
    end
end

function GameScene:refreshAvailableCommands()
    self.availableCommands = {}
    if self.humanController.awaitingIncantation and self.humanController.incantation then
        self:addAvailableCommand(self.humanController.incantation, false)
    else
        for i = 1, #self.humanController.player.hand do
            self:addAvailableCommand(self.humanController.player.hand[i].name, false)
        end
        self:addAvailableCommand(self.humanController.drawWord, false)
    end
    self:addAvailableCommand("pause", true)
    self:addAvailableCommand("quit", true)
end

function GameScene:draw()
    self.humanController:draw()
    self.enemyController:draw()

    -- Draw active spells
    if self.activeSpells then
        for i = 1, #self.activeSpells do
            local s = self.activeSpells[i]
            s:draw()
        end
    end
end

-- Spotlight/search-style input bar for the main gameplay scene.
function GameScene:drawInputInterface()
    local ui = self.ctx.ui

    local text = ui.input
    local color = COLORS.WHITE
    local isTyping = ui.input ~= ""
    if text == "" then
        text = ui.messageLeft or ""
        color = COLORS.GREY
    end

    local font = self.ctx.fonts.fontM
    local barWidth = 512
    local wrappedText = nil
    if isTyping and self.suggestedCommand then
        text = {
            COLORS.WHITE, text,
            COLORS.GREY, string.sub(self.suggestedCommand, #text + 1, -1),
        }
        _, wrappedText = font:getWrap(self.suggestedCommand, barWidth - 16)
    else
        _, wrappedText = font:getWrap(text, barWidth - 16)
    end
    local barHeight = #wrappedText * (font:getHeight() * font:getLineHeight()) + 8
    local x = math.floor((GAME_WIDTH - barWidth) / 2)
    local y = 200

    -- Bar background + outline.
    lg.setColor(COLORS.BLACK)
    lg.rectangle("fill", x, y, barWidth, barHeight)

    -- Text
    lg.setFont(font)
    lg.setColor(color)
    lg.printf(text, x + 8, y, barWidth - 16, "left")

    -- Control hint
    lg.setFont(self.ctx.fonts.fontS)
    lg.setColor(COLORS.WHITE)
    lg.printf(ui.messageRight, x + 8, y + barHeight + 4, barWidth - 16, "left")
end

function GameScene:keypressed(key)
    BaseScene.keypressed(self, key)

    if key == "escape" then
        self.ctx.sceneManager:pushScene(SceneId.Pause)
    end
end

function GameScene:handleInput(userInput)
    if userInput == "quit" then
        self.ctx.sceneManager:changeScene(SceneId.Menu)
        return
    elseif userInput == "pause" then
        self.ctx.sceneManager:pushScene(SceneId.Pause)
        return
    end

    local result = self.humanController:handleInput(userInput)
    if result == InputResult.DrawFail then
        self.ctx.ui.messageLeft = "hand full, can't draw"
    elseif result == InputResult.DrawSuccess then
        self.ctx.ui.messageLeft = "drew a card"
    elseif result == InputResult.CardSelected then
        self.ctx.ui.messageLeft = tostring(self.humanController.incantation)
    elseif result == InputResult.IncantationMismatch then
        self.ctx.ui.messageLeft = tostring(self.humanController.incantation)
    elseif result == InputResult.CastCard.Success then
        self.ctx.ui.messageLeft = "cast " .. tostring(self.humanController.lastAttemptedCardName)
    elseif castFailureMessages[result] then
        self.ctx.ui.messageLeft = "cannot cast " .. tostring(self.humanController.lastAttemptedCardName) .. ": " .. castFailureMessages[result]
    elseif result == InputResult.Unknown then
        self.ctx.ui.messageLeft = "unknown command: " .. userInput
    end

    -- Available commands should only change when the user types a new command
    self:refreshAvailableCommands()
    self:updateSuggestedCommand()
end
