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
    scene.controlsHint = "[play] game, [quit]"
    scene:addAvailableCommand("play", true)
    scene:addAvailableCommand("quit", true)
    scene.controllers = {}
    for i, charName in ipairs(ctx.characterManager:getAllCharNames()) do
        local controller = AIPlayerController:new(ctx, BasePlayer:new(ctx, ctx.characterManager:createCharacter(charName)))
        controller.renderer.tint = COLORS.WHITE
        controller.renderer.mirror = false
        controller.renderer.handX = GAME_WIDTH / 2
        table.insert(scene.controllers, controller)
        scene:addAvailableCommand(charName, true)
    end
    scene.charSelected = nil -- Stores the controller of the selected character
    return scene
end

function CharacterSelectScene:enter()
    self.ctx.ui.input = ""
    self.ctx.ui.messageLeft = self.controlsHint
    self.ctx.ui.messageRight = "choose your character"
    self.charSelected = nil
    self.charMargin = 200 -- Distance between characters
    self.startX = (GAME_WIDTH + self.charMargin - #self.controllers * (SPRITE_SIZE + self.charMargin)) / 2

    for i, controller in ipairs(self.controllers) do
        controller:reset()
        controller.player.hand = controller.player.deck
    end
end

function CharacterSelectScene:update(dt)
    if self.charSelected == nil then
        for i, controller in ipairs(self.controllers) do
            controller.renderer:updateCharAnimations(dt)
            controller.renderer.x = self.startX + (i - 1) * (SPRITE_SIZE + self.charMargin)
        end
    else
        self.charSelected.renderer:updateCharAnimations(dt)
        self.charSelected.renderer:updateHand(dt)
    end
end

function CharacterSelectScene:draw()
    local fonts = self.ctx.fonts
    if self.charSelected == nil then
        lg.setFont(fonts.fontM)
        lg.printf("type name to", 0, 200, GAME_WIDTH, "center")
        lg.setFont(fonts.fontL)
        lg.printf("choose your character", 0, 224, GAME_WIDTH, "center")

        lg.setFont(fonts.fontM)
        for i, controller in ipairs(self.controllers) do
            local char = controller.player.character
            local y = controller.renderer.y
            lg.printf(char.name, self.startX + (i - 1) * (SPRITE_SIZE + self.charMargin), y - 24, SPRITE_SIZE,
                "center")
            controller.renderer:drawChar()
        end
    else
        local char = self.charSelected.player.character
        lg.setFont(fonts.fontM)
        lg.printf("you have selected the", 200, 200, GAME_WIDTH, "left")
        lg.setFont(fonts.fontXL)
        lg.printf(char.name, 200, 208, GAME_WIDTH, "left")
        lg.setFont(fonts.fontM)
        lg.printf(char.description, 200, 284, GAME_WIDTH - 200, "left")

        self.charSelected.renderer.x = 256
        self.charSelected.renderer:drawChar()
        self.charSelected.renderer:drawHand()
    end
end

function CharacterSelectScene:handleInput(userInput)
    for _, controller in ipairs(self.controllers) do
        local char = controller.player.character
        if userInput == char.name then
            self.charSelected = controller
            self.ctx.ui.messageRight = "selected " .. char.name
            return
        end
    end

    if userInput == "play" then
        if not self.charSelected then
            self.ctx.ui.messageRight = "please select a character first"
            return
        end

        local selectedName = self.charSelected.player.character.name
        -- Seed a simple linear run of opponents and start at stage 1
        self.ctx.runState:startRun(selectedName, { "wizard", "wizard", "wizard", "wizard", "wizard" })
        local oppName = self.ctx.runState:getCurrentOpponent()
        self.ctx.sceneManager:getScene(SceneId.Game):setHumanController(
            HumanPlayerController:new(self.ctx, BasePlayer:new(self.ctx, self.ctx.characterManager:createCharacter(selectedName))))
        self.ctx.sceneManager:getScene(SceneId.Game):setEnemyController(
            AIPlayerController:new(self.ctx, BasePlayer:new(self.ctx, self.ctx.characterManager:createCharacter(oppName)), "normal"))
        self.ctx.sceneManager:changeScene(SceneId.Game)
    elseif userInput == "quit" then
        if self.charSelected then
            -- Deselect the character
            self.charSelected = nil
            self.ctx.ui.messageRight = "choose your character"
        else
            self.ctx.sceneManager:changeScene(SceneId.Menu)
        end
    end
end
