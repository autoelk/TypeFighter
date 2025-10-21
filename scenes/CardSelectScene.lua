require "scenes.BaseScene"

-- Card Selection Scene
CardSelectScene = {}
setmetatable(CardSelectScene, {
    __index = BaseScene
})
CardSelectScene.__index = CardSelectScene

function CardSelectScene:new()
    local scene = setmetatable(BaseScene:new(), self)
    scene.name = "cardSelect"
    scene.posy = 10 -- scroll position
    scene.cardsPerRow = 4
    scene.cardPool = {}
    scene.controlsHint = "[p]lay [q] to go back"
    return scene
end

function CardSelectScene:enter()
    messageRight = self.controlsHint
    self.cardPool = {}
    for _, cardName in ipairs(cardManager:getAllCardNames()) do
        table.insert(self.cardPool, cardManager:createCard(cardName))
    end
    -- Reset player picks for card selection
    HUMANPLAYERCONTROLLER.player.picks = MAX_DECK_SIZE
    HUMANPLAYERCONTROLLER.player.deck = {}
    AIPLAYERCONTROLLER.player.picks = MAX_DECK_SIZE
    AIPLAYERCONTROLLER.player.deck = {}

    -- TODO Change way AI deck is populated
    while AIPLAYERCONTROLLER.player.picks > 0 do
        local cardIdx = math.random(1, #self.cardPool)
        AIPLAYERCONTROLLER.player:addCard(self.cardPool[cardIdx])
        table.remove(self.cardPool, cardIdx)
    end
end

function CardSelectScene:update(dt)
    local margin = 10

    for i = 1, #self.cardPool do
        self.cardPool[i]:update(dt)
    end

    for i = 1, #AIPLAYERCONTROLLER.player.deck do
        AIPLAYERCONTROLLER.player.deck[i]:update(dt)
        AIPLAYERCONTROLLER.player.deck[i]:move(GAME_WIDTH - LARGE_CARD_WIDTH - margin, 25 * (i - 1) + margin + 40)
    end

    for i = 1, #HUMANPLAYERCONTROLLER.player.deck do
        HUMANPLAYERCONTROLLER.player.deck[i]:update(dt)
        HUMANPLAYERCONTROLLER.player.deck[i]:move(margin, 25 * (i - 1) + margin + 40)
    end

    -- draw remaining cards
    local remCardIdx = 0
    local colSpacing = LARGE_CARD_WIDTH + margin
    local rowSpacing = LARGE_CARD_HEIGHT + margin
    local displayWidth = self.cardsPerRow * colSpacing + margin
    local startX = (GAME_WIDTH - displayWidth) / 2 + margin
    for i = 1, #self.cardPool do
        local colNum, rowNum = remCardIdx % self.cardsPerRow, math.floor(remCardIdx / self.cardsPerRow)
        local x = startX + colSpacing * colNum
        local y = rowSpacing * rowNum + self.posy
        self.cardPool[i]:move(x, y)
        remCardIdx = remCardIdx + 1
    end
end

function CardSelectScene:draw()
    local margin = 10

    lg.setFont(fontM)
    lg.setColor(COLORS.WHITE)
    lg.printf("your deck " .. #HUMANPLAYERCONTROLLER.player.deck .. "/" .. MAX_DECK_SIZE, margin, margin,
        LARGE_CARD_WIDTH, "center")
    lg.printf("opp deck " .. #AIPLAYERCONTROLLER.player.deck .. "/" .. MAX_DECK_SIZE,
        GAME_WIDTH - LARGE_CARD_WIDTH - margin, margin,
        LARGE_CARD_WIDTH, "center")

    for i = 1, #self.cardPool do
        self.cardPool[i]:draw()
    end

    for i = 1, #HUMANPLAYERCONTROLLER.player.deck do
        HUMANPLAYERCONTROLLER.player.deck[i]:draw()
    end

    for i = 1, #AIPLAYERCONTROLLER.player.deck do
        AIPLAYERCONTROLLER.player.deck[i]:draw()
    end

    -- When both players have full decks, prompt player to start
    if #HUMANPLAYERCONTROLLER.player.deck == MAX_DECK_SIZE and #AIPLAYERCONTROLLER.player.deck == MAX_DECK_SIZE then
        lg.setFont(fontL)
        lg.setColor(COLORS.BLACK)
        lg.rectangle("fill", 0, 300, GAME_WIDTH, 50)
        lg.setColor(COLORS.WHITE)
        lg.printf("both decks full, type [p] to start", 0, 300, GAME_WIDTH, "center")
    end
end

function CardSelectScene:keypressed(key)
    if key == "return" then
        local userInput = self:processInput()

        -- Check if the user typed a card name
        local isCardName = false

        for _, cardName in ipairs(cardManager:getAllCardNames()) do
            if userInput == cardName:lower() then
                isCardName = true
            end
        end

        if isCardName then
            self:handleCardSelection(userInput)
        elseif userInput == "start" or userInput == "p" then
            self:handleGameStart()
        elseif userInput == "q" or userInput == "quit" then
            self.sceneManager:changeScene("menu")
        else
            messageLeft = "type card names to choose them"
        end
        input = ""
    end
end

function CardSelectScene:handleCardSelection(cardName)
    for i = 1, #HUMANPLAYERCONTROLLER.player.deck do
        if HUMANPLAYERCONTROLLER.player.deck[i].name:lower() == cardName then
            table.insert(self.cardPool, HUMANPLAYERCONTROLLER.player.deck[i])
            HUMANPLAYERCONTROLLER.player:removeCard(HUMANPLAYERCONTROLLER.player.deck[i])
            messageLeft = "removed " .. HUMANPLAYERCONTROLLER.player.deck[i].name
            return
        end
    end

    for i = 1, #AIPLAYERCONTROLLER.player.deck do
        if AIPLAYERCONTROLLER.player.deck[i].name:lower() == cardName then
            messageLeft = cardName .. " is in opponent's deck"
            return
        end
    end

    for i = 1, #self.cardPool do
        if self.cardPool[i].name:lower() == cardName then
            if #HUMANPLAYERCONTROLLER.player.deck >= MAX_DECK_SIZE then
                messageLeft = "your deck is full"
            elseif HUMANPLAYERCONTROLLER.player.picks <= 0 then
                messageLeft = "no picks remaining"
            else
                HUMANPLAYERCONTROLLER.player:addCard(self.cardPool[i])
                messageLeft = "added " .. self.cardPool[i].name
                table.remove(self.cardPool, i)
            end
            return
        end
    end
end

function CardSelectScene:handleGameStart()
    if HUMANPLAYERCONTROLLER.player.picks > 0 then
        messageLeft = "you have " .. HUMANPLAYERCONTROLLER.player.picks .. " picks left"
    elseif AIPLAYERCONTROLLER.player.picks > 0 then
        messageLeft = "opponent has " .. AIPLAYERCONTROLLER.player.picks .. " picks left"
    else
        messageLeft = "game started"
        self.sceneManager:changeScene("game")
    end
end

function CardSelectScene:wheelmoved(x, y)
    self.posy = self.posy + y * SCROLL_SPEED

    -- Calculate bounds based on grid height
    local margin = 10
    local rows = math.ceil(math.max(#self.cardPool, 1) / self.cardsPerRow)
    local gridHeight = rows * (LARGE_CARD_HEIGHT + margin)

    local headerHeight = 40
    local visibleHeight = GAME_HEIGHT - headerHeight - 80

    local topLimit = margin
    local minPosy = math.min(topLimit, visibleHeight - gridHeight)

    if self.posy > topLimit then self.posy = topLimit end
    if self.posy < minPosy then self.posy = minPosy end
end
