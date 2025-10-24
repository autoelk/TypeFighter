require "scenes.BaseScene"

CharacterSelectScene = {}
setmetatable(CharacterSelectScene, {
    __index = BaseScene
})
CharacterSelectScene.__index = CharacterSelectScene

-- TODO: Make the selected character automatically cast spells on a target dummy
function CharacterSelectScene:new()
    local scene = setmetatable(BaseScene:new(), self)
    scene.name = "characterSelect"
    scene.controlsHint = "[p] to continue [q] to go back"
    scene.controllers = {}
    for i, charName in ipairs(characterManager:getAllCharNames()) do
        local char = characterManager:createCharacter(charName)
        local player = BasePlayer:new(char)
        local controller = AIPlayerController:new(player)
        controller.tint = COLORS.WHITE
        controller.mirror = false
        controller.libraryX = GAME_WIDTH / 2
        table.insert(scene.controllers, controller)
    end
    scene.charSelected = nil -- Stores the controller of the selected character
    return scene
end

function CharacterSelectScene:enter()
    input = ""
    messageLeft = "choose your character"
    messageRight = self.controlsHint
    self.charMargin = 200
    self.startX = (GAME_WIDTH + self.charMargin - #self.controllers * (SPRITE_SIZE + self.charMargin)) / 2

    for i, controller in ipairs(self.controllers) do
        controller.player:reset()
        controller.player.hand = controller.player.deck
    end
end

function CharacterSelectScene:update(dt)
    if self.charSelected == nil then
        for i, controller in ipairs(self.controllers) do
            controller:updateCharAnimations(dt)
            controller.x = self.startX + (i - 1) * (SPRITE_SIZE + self.charMargin)
            controller.y = 375
        end
    else
        self.charSelected:updateCharAnimations(dt)
        self.charSelected:updateHand(dt)
    end
end

function CharacterSelectScene:draw()
    if self.charSelected == nil then
        lg.setFont(fontM)
        lg.printf("type name to", 0, 200, GAME_WIDTH, "center")
        lg.setFont(fontL)
        lg.printf("choose your character", 0, 225, GAME_WIDTH, "center")

        lg.setFont(fontM)
        for i, controller in ipairs(self.controllers) do
            local char = controller.player.character
            lg.printf(char.name, self.startX + (i - 1) * (SPRITE_SIZE + self.charMargin), 375 - 25, SPRITE_SIZE,
                "center")
            controller:drawChar()
        end
    else
        local char = self.charSelected.player.character
        lg.setFont(fontM)
        lg.printf("you have selected the", 200, 250, GAME_WIDTH, "left")
        lg.setFont(fontXL)
        lg.printf(char.name, 200, 250, GAME_WIDTH, "left")
        lg.setFont(fontM)
        lg.printf(char.description, 200, 350, GAME_WIDTH - 200, "left")

        self.charSelected.x = 200
        self.charSelected.y = 375
        self.charSelected:drawChar()
        self.charSelected:drawHand()
    end
end

function CharacterSelectScene:handleInput(userInput)
    for _, controller in ipairs(self.controllers) do
        local char = controller.player.character
        if userInput == char.name then
            self.charSelected = controller
            messageLeft = "selected " .. char.name
            return
        end
    end

    if userInput == "p" or userInput == "play game" then
        if not self.charSelected then
            messageLeft = "please select a character first"
            return
        end
        local selectedName = self.charSelected.player.character.name
        self.sceneManager:getScene("game"):setPlayer1(
            HumanPlayerController:new(BasePlayer:new(characterManager:createCharacter(selectedName))))
        -- TODO: Make this change based on level
        self.sceneManager:getScene("game"):setPlayer2(
            AIPlayerController:new(BasePlayer:new(characterManager:createCharacter("wizard")), "normal"))
        self.sceneManager:changeScene("game")
    elseif userInput == "q" or userInput == "quit" then
        if self.charSelected then
            self.charSelected = nil
            messageLeft = "choose your character"
            return
        end
        self.sceneManager:changeScene("menu")
    end
end
