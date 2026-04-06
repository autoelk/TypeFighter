require "scenes.BaseScene"
local InputResult = require "enums.InputResult"
local Text = require "util.Text"
local Table = require "util.Table"
local SceneId = require "enums.SceneId"

local castFailureMessages = {
    [InputResult.CastCard.InsufficientHealth] = "insufficient health",
    [InputResult.CastCard.CannotCast] = "cannot cast",
}

-- Battle Scene, represents a single match between two players
BattleScene = {}
setmetatable(BattleScene, {
    __index = BaseScene
})
BattleScene.__index = BattleScene

function BattleScene:new(ctx)
    local scene = setmetatable(BaseScene:new(ctx), self)
    scene.name = SceneId.Battle
    scene.controlsHint = "[quit] to menu, [pause]"
    scene:addAvailableCommand("quit", true)
    scene:addAvailableCommand("pause", true)
    scene.humanController = nil
    scene.enemyController = nil
    scene.activeSpells = {}
    scene.gameOverTriggered = false
    scene.inputBarState = "normal" -- normal, incantation
    return scene
end

function BattleScene:setHumanController(controller)
    self.humanController = controller
    if self.enemyController ~= nil then
        self.humanController:setOpponent(self.enemyController)
        self.enemyController:setOpponent(self.humanController)
    end
end

function BattleScene:setEnemyController(controller)
    self.enemyController = controller
    if self.humanController ~= nil then
        self.humanController:setOpponent(self.enemyController)
        self.enemyController:setOpponent(self.humanController)
    end
end

function BattleScene:enter()
    self.humanController:reset()
    self.enemyController:reset()

    Table.shuffle(self.humanController.player.library)
    Table.shuffle(self.enemyController.player.library)

    -- set all card positions to library
    for _, card in ipairs(self.humanController.player.library) do
        card:setPosition(self.humanController.renderer.libraryX, self.humanController.renderer.libraryY)
    end
    local enemyLibraryX = GAME_WIDTH + 16
    local enemyLibraryY = GAME_HEIGHT / 2
    for _, card in ipairs(self.enemyController.player.library) do
        card:setPosition(enemyLibraryX, enemyLibraryY)
    end

    -- draw starting hands
    for i = 1, STARTING_HAND_SIZE do
        self.humanController.player:drawCard()
        self.enemyController.player:drawCard()
    end

    -- set game interface messages
    self.ctx.ui.input = ""
    self.ctx.ui.messageLeft = self.controlsHint
    self.ctx.ui.messageRight = "type card name, then type the incantation to cast"

    -- initialize active spells list for this game
    self.activeSpells = {}
    self.gameOverTriggered = false
    self.inputBarState = "normal"
    self:refreshAvailableCommands()
end

function BattleScene:update(dt)
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
            self.ctx.sceneManager:pushScene(SceneId.BattleEnd)
        end
    end
end

function BattleScene:updateSuggestedCommand()
    local matchingCommands = self:getAvailableCommands(self.ctx.ui.input)
    if self.inputBarState == "incantation" then
        if #matchingCommands == 1 then
            self.suggestedCommand = matchingCommands[1]
            self.suggestedCommandAutocomplete = self.availableCommands[self.suggestedCommand]
        else
            self.suggestedCommand = self.humanController.incantation
            self.suggestedCommandAutocomplete = false
        end
    else
        BaseScene.updateSuggestedCommand(self)
    end
end

function BattleScene:refreshAvailableCommands()
    self.availableCommands = {}
    self:addAvailableCommand("quit", true)
    if self.inputBarState == "incantation" then
        self:addAvailableCommand(self.humanController.incantation, false)
        self:addAvailableCommand("cancel", true)
        self.ctx.ui.messageLeft = tostring(self.humanController.incantation)
        self.ctx.ui.messageRight = "type incantation above to cast"
    else
        -- normal input bar
        for i = 1, #self.humanController.player.hand do
            self:addAvailableCommand(self.humanController.player.hand[i].name, true)
        end
        self:addAvailableCommand(self.humanController.drawWord, false)
        self:addAvailableCommand("pause", true)
        self:removeAvailableCommand("cancel")
        -- self.ctx.ui.messageLeft = self.humanController.drawWord
        if self.humanController.player:canDrawCard() then
            self.ctx.ui.messageRight = "type \"" .. self.humanController.drawWord .. "\" to draw, or type card name to cast"
        else
            self.ctx.ui.messageRight = "type card name to cast"
        end
    end
end

function BattleScene:draw()
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

-- input bar for the main gameplay scene.
function BattleScene:drawInputInterface()
    local ui = self.ctx.ui
    local text = ui.input
    local barWidth = 512
    
    local cursorWidth = 10
    local cursorHeight = 2
    local progCurWord, remCurWord = "", ""
    local modifiedInput = ui.input -- used for cursor positioning for incantation typing
    
    local color = COLORS.WHITE
    if ui.input == "" then
        -- if the user hasn't typed anything, show the reminder text.
        if self.inputBarState == "normal" then
            text = ui.messageLeft or ""
        elseif self.inputBarState == "incantation" then
            text = tostring(self.humanController.incantation)
        end
        color = COLORS.GREY
    elseif ui.input ~= "" and self.suggestedCommand then
        -- user is typing and we have a suggested command
        if self.inputBarState == "incantation" and self.suggestedCommand == self.humanController.incantation then
            text, progCurWord, remCurWord, modifiedInput = Text.colorizeIncantation(self.humanController.incantation, ui.input)
        else
            text = Text.colorizeText(self.suggestedCommand, ui.input, COLORS.WHITE, COLORS.WHITE, COLORS.GREY)
        end
    end
    
    local x = math.floor((GAME_WIDTH - barWidth) / 2)
    local y = 200
    local font = self.ctx.fonts.fontM
    
    local _, wrappedText = font:getWrap(text, barWidth - 16)
    local barHeight = #wrappedText * (font:getHeight() * font:getLineHeight()) + 8
    
    -- cursor placement
    local _, wrappedInput = font:getWrap(modifiedInput, barWidth - 16)
    local _, wrappedInputWithWord = font:getWrap(modifiedInput .. remCurWord, barWidth - 16)
    local cursorX = x + font:getWidth(wrappedInput[#wrappedInput]) + 8
    local cursorY = y + #wrappedInput * (font:getHeight() * font:getLineHeight()) + 2
    if #wrappedInputWithWord > #wrappedInput then
        -- if finishing the current word causes wrapping
        cursorX = x + font:getWidth(progCurWord) + 8
        cursorY = y + #wrappedInputWithWord * (font:getHeight() * font:getLineHeight()) + 2
    end

    -- bar background and outline
    lg.setColor(COLORS.BLACK)
    lg.rectangle("fill", x, y, barWidth, barHeight)

    -- text
    lg.setFont(font)
    lg.setColor(color)
    lg.printf(text, x + 8, y, barWidth - 16, "left")

    -- cursor
    lg.setColor(COLORS.WHITE)
    lg.rectangle("fill", cursorX, cursorY, cursorWidth, cursorHeight)

    -- feedback below the bar
    lg.setFont(self.ctx.fonts.fontS)
    lg.setColor(COLORS.WHITE)
    lg.printf(ui.messageRight, x + 8, y + barHeight + 4, barWidth - 16, "left")
end

function BattleScene:keypressed(key)
    BaseScene.keypressed(self, key)

    if key == "escape" then
        self.ctx.sceneManager:pushScene(SceneId.Pause)
    end
end

function BattleScene:handleInput(userInput)
    if self.inputBarState == "normal" and userInput == "quit" then
        self.ctx.runState:endRun()
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
