require "scenes.BaseScene"
local SceneId = require "enums.SceneId"

CharacterSelectScene = {}
setmetatable(CharacterSelectScene, {
    __index = BaseScene
})
CharacterSelectScene.__index = CharacterSelectScene

-- TODO: Make the selected character automatically cast spells on a target dummy
function CharacterSelectScene:new(ctx)
    local scene = setmetatable(BaseScene:new(ctx), self)
    scene.name = SceneId.CharacterSelect
    scene.controlsHint = "[p] to continue [q] to go back"
    scene.controllers = {}
    for i, charName in ipairs(ctx.characterManager:getAllCharNames()) do
        local char = ctx.characterManager:createCharacter(charName)
        local player = BasePlayer:new(ctx, char)
        local controller = AIPlayerController:new(ctx, player)
        controller.tint = COLORS.WHITE
        controller.mirror = false
        controller.libraryX = GAME_WIDTH / 2
        table.insert(scene.controllers, controller)
    end
    scene.charSelected = nil -- Stores the controller of the selected character
    return scene
end

function CharacterSelectScene:enter()
    self.ctx.ui.input = ""
    self.ctx.ui.messageLeft = "choose your character"
    self.ctx.ui.messageRight = self.controlsHint
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
    local fonts = self.ctx.fonts
    if self.charSelected == nil then
        lg.setFont(fonts.fontM)
        lg.printf("type name to", 0, 200, GAME_WIDTH, "center")
        lg.setFont(fonts.fontL)
        lg.printf("choose your character", 0, 225, GAME_WIDTH, "center")

        lg.setFont(fonts.fontM)
        for i, controller in ipairs(self.controllers) do
            local char = controller.player.character
            lg.printf(char.name, self.startX + (i - 1) * (SPRITE_SIZE + self.charMargin), 375 - 25, SPRITE_SIZE,
                "center")
            controller:drawChar()
        end
    else
        local char = self.charSelected.player.character
        lg.setFont(fonts.fontM)
        lg.printf("you have selected the", 200, 250, GAME_WIDTH, "left")
        lg.setFont(fonts.fontXL)
        lg.printf(char.name, 200, 250, GAME_WIDTH, "left")
        lg.setFont(fonts.fontM)
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
            self.ctx.ui.messageLeft = "selected " .. char.name
            return
        end
    end

    if userInput == "p" or userInput == "play game" then
        if not self.charSelected then
            self.ctx.ui.messageLeft = "please select a character first"
            return
        end

        local selectedName = self.charSelected.player.character.name
        -- Seed a simple linear run of opponents and start at stage 1
        self.ctx.runState:startRun(selectedName, { "wizard", "wizard", "wizard", "wizard", "wizard" })
        local oppName = self.ctx.runState:getCurrentOpponent()
        self.ctx.sceneManager:getScene(SceneId.Game):setPlayer1(
            HumanPlayerController:new(self.ctx, BasePlayer:new(self.ctx, self.ctx.characterManager:createCharacter(selectedName))))
        self.ctx.sceneManager:getScene(SceneId.Game):setPlayer2(
            AIPlayerController:new(self.ctx, BasePlayer:new(self.ctx, self.ctx.characterManager:createCharacter(oppName)), "normal"))
        self.ctx.sceneManager:changeScene(SceneId.Game)
    elseif userInput == "q" or userInput == "quit" then
        if self.charSelected then
            -- Deselect the character
            self.charSelected = nil
            self.ctx.ui.messageLeft = "choose your character"
            return
        end
        self.ctx.sceneManager:changeScene(SceneId.Menu)
    end
end
