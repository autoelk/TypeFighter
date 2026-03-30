require "scenes.BaseScene"
local InputResult = require "enums.InputResult"
local SceneId = require "enums.SceneId"

local castFailureMessages = {
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
    scene.controlsHint = "[quit] to menu, [pause]" -- Unused for now
    scene:addAvailableCommand("quit", true)
    scene:addAvailableCommand("pause", true)
    scene.humanController = nil
    scene.enemyController = nil
    scene.activeSpells = {}
    scene.gameOverTriggered = false
    scene.inputBarState = "normal" -- normal, incantation
    return scene
end

function GameScene:setHumanController(controller)
    self.humanController = controller
    if self.enemyController ~= nil then
        self.humanController:setOpponent(self.enemyController)
        self.enemyController:setOpponent(self.humanController)
    end
end

function GameScene:setEnemyController(controller)
    self.enemyController = controller
    if self.humanController ~= nil then
        self.humanController:setOpponent(self.enemyController)
        self.enemyController:setOpponent(self.humanController)
    end
end

function GameScene:enter()
    -- Initialize players for gameplay
    self.humanController:reset()
    self.enemyController:reset()

    self.humanController.player.library = self.humanController.player.deck
    self.enemyController.player.library = self.enemyController.player.deck

    -- TODO: Shuffle decks

    -- Set all card positions to library
    for _, card in ipairs(self.humanController.player.library) do
        card:setPosition(self.humanController.renderer.libraryX, self.humanController.renderer.libraryY)
    end
    local enemyLibraryX = GAME_WIDTH + 16
    local enemyLibraryY = GAME_HEIGHT / 2
    for _, card in ipairs(self.enemyController.player.library) do
        card:setPosition(enemyLibraryX, enemyLibraryY)
    end

    -- Draw starting hands
    for i = 1, STARTING_HAND_SIZE do
        self.humanController.player:drawCard()
        self.enemyController.player:drawCard()
    end

    -- Set game interface messages
    self.ctx.ui.input = ""
    self.ctx.ui.messageLeft = self.controlsHint
    self.ctx.ui.messageRight = "type card name, then type the incantation to cast"

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
    if self.inputBarState == "incantation" then
        self:addAvailableCommand(self.humanController.incantation, false)
        self:addAvailableCommand("quit", true)
        self.ctx.ui.messageLeft = tostring(self.humanController.incantation)
        self.ctx.ui.messageRight = "type incantation above to cast"
    else
        for i = 1, #self.humanController.player.hand do
            self:addAvailableCommand(self.humanController.player.hand[i].name, false)
        end
        self:addAvailableCommand(self.humanController.drawWord, false)
        self:addAvailableCommand("pause", true)
        self:addAvailableCommand("quit", true)
        -- self.ctx.ui.messageLeft = self.humanController.drawWord
        if self.humanController.player:canDrawCard() then
            self.ctx.ui.messageRight = "type \"" .. self.humanController.drawWord .. "\" to draw, or type card name to cast"
        else
            self.ctx.ui.messageRight = "type card name to cast"
        end
    end
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
        if text == "" and self.inputBarState == "incantation" then
            text = tostring(self.humanController.incantation)
        end
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

    -- Feedback (instructions / errors) below the bar
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
    if self.inputBarState == "normal" and userInput == "quit" then
        self.ctx.sceneManager:changeScene(SceneId.Menu)
        return
    elseif userInput == "pause" then
        self.ctx.sceneManager:pushScene(SceneId.Pause)
        return
    end

    local result = nil
    if self.inputBarState == "normal" then
        result = self.humanController:handleInput(userInput)
    elseif self.inputBarState == "incantation" then
        result = self.humanController:handleIncantationInput(userInput)
    end

    if result == InputResult.DrawFail then
        self.ctx.ui.messageRight = "you failed to draw a card"
    elseif result == InputResult.CardSelected then
        self.inputBarState = "incantation"
    elseif result == InputResult.DrawSuccess then
        -- self.ctx.ui.messageRight = "drew a card"
    elseif result == InputResult.IncantationCancelled then
        self.ctx.ui.messageRight = "you cancelled casting " .. tostring(self.humanController.lastAttemptedCardName)
        self.inputBarState = "normal"
    elseif result == InputResult.CastCard.Success then
        self.inputBarState = "normal"
    elseif castFailureMessages[result] then
        self.ctx.ui.messageRight = "you cannot cast " .. tostring(self.humanController.lastAttemptedCardName) .. ": " .. castFailureMessages[result]
    elseif result == InputResult.Unknown then
        self.ctx.ui.messageRight = "unknown command \"" .. userInput .. "\""
    end

    -- Available commands should only change when the user types a new command
    self:refreshAvailableCommands()
    self:updateSuggestedCommand()
end
