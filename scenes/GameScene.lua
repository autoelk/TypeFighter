require "scenes.BaseScene"

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
    HUMANPLAYER:reset()
    AIPLAYER:reset()

    HUMANPLAYER.library = HUMANPLAYER.deck
    AIPLAYER.library = AIPLAYER.deck

    -- Draw starting hands
    for i = 1, STARTING_HAND_SIZE do
        HUMANPLAYER:drawCard()
        AIPLAYER:drawCard()
    end

    -- Set game interface messages
    messageLeft = "type card names to cast them"
    messageRight = self.controlsHint

    -- Initialize active spells list for this game
    self.activeSpells = {}
end

function GameScene:update(dt)
    HUMANPLAYER:update(dt)
    AIPLAYER:update(dt)

    -- Update active spells
    for i = #self.activeSpells, 1, -1 do
        local spell = self.activeSpells[i]
        if spell.anim.timeLeft and spell.anim.timeLeft <= 0 then
            table.remove(self.activeSpells, i)
        else
            spell:update(dt)
        end
    end

    local margin = 10
    for i = 1, #HUMANPLAYER.hand do
        HUMANPLAYER.hand[i]:update(dt)
        HUMANPLAYER.hand[i]:move(margin, (MINI_CARD_HEIGHT + margin) * i + 100)
    end

    for i = 1, #AIPLAYER.hand do
        if AIPLAYER.hand[i] == AIPLAYER.nextSpell then
            AIPLAYER.hand[i]:move(GAME_WIDTH - MINI_CARD_WIDTH - margin - 40,
                (MINI_CARD_HEIGHT + margin) * i + 100)
        else
            AIPLAYER.hand[i]:move(GAME_WIDTH - MINI_CARD_WIDTH - margin,
                (MINI_CARD_HEIGHT + margin) * i + 100)
        end
    end


    if not HUMANPLAYER.isAlive or not AIPLAYER.isAlive then
        self.sceneManager:changeScene("gameOver")
    end
end

function GameScene:draw()
    -- Display decks
    local margin = 10

    for i = 1, #HUMANPLAYER.hand do
        HUMANPLAYER.hand[i]:drawMini()
    end

    -- Display word for player to type in order to draw a card
    if #HUMANPLAYER.hand < MAX_HAND_SIZE then
        HUMANPLAYER:drawDictWord(margin, (MINI_CARD_HEIGHT + margin) * (#HUMANPLAYER.hand + 1) + 100)
    end

    for i = 1, #AIPLAYER.hand do
        AIPLAYER.hand[i]:drawMini()
    end

    lg.setColor(COLORS.WHITE)
    HUMANPLAYER:draw()
    AIPLAYER:draw()

    -- Draw active spells
    if self.activeSpells then
        for i = 1, #self.activeSpells do
            local s = self.activeSpells[i]
            s:draw()
        end
    end

    HUMANPLAYER:drawUI()
    AIPLAYER:drawUI()
end

function GameScene:keypressed(key)
    if key == "escape" then
        self.sceneManager:pushScene("pause")
    elseif key == "return" then
        local userInput = self:processInput()
        local result = HUMANPLAYER:handleInput(userInput)

        if result == "quit" then
            self.sceneManager:changeScene("menu")
        elseif result == "unknown_card" then
            messageLeft = "type card names to cast them"
        elseif result == "insufficient_mana" then
        elseif result == "not_your_card" then
            messageLeft = "that card is not in your deck"
        elseif result == "cannot_cast" then
        end
        input = ""
    end
end
