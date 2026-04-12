require "scenes.BaseScene"
local SceneId = require "enums.SceneId"
local Text = require "util.Text"

-- Battle End Scene
-- shows rewards for winning the battle
BattleEndScene = {}
setmetatable(BattleEndScene, {
    __index = BaseScene
})
BattleEndScene.__index = BattleEndScene

function BattleEndScene:new(ctx)
    local scene = setmetatable(BaseScene:new(ctx), self)
    scene.name = SceneId.BattleEnd
    scene.controlsHint = "[skip] reward, [quit] to menu"
    scene:addAvailableCommand("skip", true)
    scene:addAvailableCommand("quit", true)
    scene.title = ""
    scene.subtitle = ""
    scene.mode = "card" -- card, word
    scene.rewards = {
        cards = {},
        words = {}
    }
    return scene
end

function BattleEndScene:enter()
    local game = self.ctx.sceneManager:getScene(SceneId.Battle)
    self.mode = "card"

    local rs = self.ctx.runState
    local p1Alive = game.humanController.player.isAlive
    local p2Alive = game.enemyController.player.isAlive
    if p1Alive and not p2Alive then
        -- Win this stage
        local current = rs.stageIndex
        local total = #rs.stages
        if current < total then
            self.title = "stage " .. current .. " cleared"
        else
            self.title = "final stage cleared"
        end
    else
        error("BattleEndScene:enter() called, but player is not alive")
    end

    self.cards = self.ctx.cardManager:getRandomCards(3, rs.humanPlayerController.player.character.name)
    for _, card in ipairs(self.cards) do
        card.x = (GAME_WIDTH - LARGE_CARD_WIDTH) / 2
        card.y = -LARGE_CARD_HEIGHT
        self:addAvailableCommand(card.name, true)
    end

    self.words = self.ctx.resourceManager:getRandomWords(3)
    for _, word in ipairs(self.words) do
        self:addAvailableCommand(word, true)
    end

    self.ctx.ui.input = ""
    self.ctx.ui.messageLeft = self.controlsHint
    self.ctx.ui.messageRight = ""
end

function BattleEndScene:exit()
    for _, card in ipairs(self.cards) do
        self:removeAvailableCommand(card.name)
    end

    for _, word in ipairs(self.words) do
        self:removeAvailableCommand(word)
    end
end

function BattleEndScene:update(dt)
    local card_margin = 16
    local step = LARGE_CARD_WIDTH + card_margin
    local row_width = 3 * LARGE_CARD_WIDTH + 2 * card_margin
    for i, card in ipairs(self.cards) do
        card:move((GAME_WIDTH - row_width) / 2 + (i - 1) * step, 256)
        card:update(dt)
    end
end

function BattleEndScene:draw()
    local fonts = self.ctx.fonts
    -- Dim the background
    lg.setColor(0, 0, 0, 0.5)
    lg.rectangle("fill", 0, 0, GAME_WIDTH, GAME_HEIGHT)

    -- Draw message
    lg.setColor(COLORS.WHITE)
    lg.setFont(fonts.fontXL)
    lg.printf(self.title, 0, 100, GAME_WIDTH, "center")
    lg.setFont(fonts.fontM)
    lg.printf(self.subtitle, 0, 180, GAME_WIDTH, "center")
    if self.mode == "card" then
        for _, card in ipairs(self.cards) do
            card:draw()
        end
    elseif self.mode == "word" then
        lg.setFont(fonts.fontL)
        for i, word in ipairs(self.words) do
            local coloredWord = Text.colorizeText(word, self.ctx.ui.input, COLORS.WHITE, COLORS.GREEN, COLORS.WHITE)
            lg.printf(coloredWord, 0, 256 + (i - 1) * 64, GAME_WIDTH, "center")
        end
    end
    self.ctx.ui.messageLeft = self.controlsHint
end

function BattleEndScene:handleInput(userInput)
    local rs = self.ctx.runState
    local changeMode = function(mode)
        if mode == "card" then
            self.mode = "card"
            self.subtitle = "choose a card to add to your deck"
        elseif mode == "word" then
            self.mode = "word"
            self.subtitle = "choose a word to add to your word bank"
            for _, card in ipairs(self.cards) do
                self:removeAvailableCommand(card.name)
            end
            for _, word in ipairs(self.words) do
                self:addAvailableCommand(word, true)
            end
        elseif mode == "end" then
            if rs:hasNextStage() then
                rs:advanceStage()
                local game = self.ctx.sceneManager:getScene(SceneId.Battle)
                local oppName = rs:getCurrentOpponent()
                game:setHumanController(rs.humanPlayerController)
                game:setEnemyController(AIPlayerController:new(
                    self.ctx, 
                    self.ctx.characterManager:createPlayer(self.ctx, oppName), 
                    "normal")
                )
                self.ctx.sceneManager:changeScene(SceneId.Battle)
            else
                rs:endRun()
                self.ctx.sceneManager:changeScene(SceneId.GameOver)
            end
        end
    end

    if userInput == "quit" then
        rs:endRun()
        self.ctx.sceneManager:changeScene(SceneId.Menu)
        return
    end

    if self.mode == "card" then
        for _, card in ipairs(self.cards) do
            if userInput == card.name then
                table.insert(rs.humanPlayerController.player.deck, card)
                changeMode("word")
                return
            end
        end

        if userInput == "skip" then
            changeMode("word")
        end
    elseif self.mode == "word" then
        for _, word in ipairs(self.words) do
            if userInput == word then
                table.insert(rs.humanPlayerController.player.wordBank, word)
                changeMode("end")
                return
            end
        end

        if userInput == "play" or userInput == "skip" then
            for _, word in ipairs(self.words) do
                self:removeAvailableCommand(word)
            end
            changeMode("end")
        end
    end
end
