require "scenes.BaseScene"
local SceneId = require "enums.SceneId"

-- Menu Scene
MenuScene = {}
setmetatable(MenuScene, {
    __index = BaseScene
})
MenuScene.__index = MenuScene

function MenuScene:new(ctx)
    local scene = setmetatable(BaseScene:new(ctx), self)
    scene.name = SceneId.Menu
    scene.controlsHint = "[play] game, [browse] cards, [quit]"
    scene:addAvailableCommand("play", true)
    scene:addAvailableCommand("browse", true)
    scene:addAvailableCommand("quit", true)

    -- Load characters for display
    scene.leftRenderer = BasePlayerRenderer:new(ctx, BasePlayer:new(ctx, ctx.characterManager:createCharacter("wizard")))
    scene.leftRenderer.x = 320
    scene.leftRenderer.mirror = false

    scene.rightRenderer = BasePlayerRenderer:new(ctx, BasePlayer:new(ctx, ctx.characterManager:createCharacter("vampire")))
    scene.rightRenderer.x = GAME_WIDTH - 320 - SPRITE_SIZE
    scene.rightRenderer.mirror = true

    -- Load spells for display
    scene.torrentAnimation = ctx.resourceManager:newAnimation("card_torrent")
    scene.torrentAnimation.rotation = 0
    scene.torrentAnimation:setPlayMode("loop")

    scene.fireballAnimation = ctx.resourceManager:newAnimation("card_fireball")
    scene.fireballAnimation.rotation = 180
    scene.fireballAnimation:setPlayMode("loop")

    return scene
end

function MenuScene:enter()
    self.ctx.ui.input = ""
    self.ctx.ui.messageLeft = self.controlsHint
    self.ctx.ui.messageRight = "type [play] to start"
end

function MenuScene:draw()
    local fonts = self.ctx.fonts
    lg.setColor(COLORS.WHITE)
    lg.setFont(fonts.fontXL)
    lg.printf("typefighter", 0, 200, GAME_WIDTH, "center")
    lg.setFont(fonts.fontM)
    lg.printf("[play] game\n[browse] cards\n[quit]", 0, 300, GAME_WIDTH, "center")
    
    local margin = 340
    self.torrentAnimation:draw(margin, 180)
    self.fireballAnimation:draw(GAME_WIDTH - margin, 180 + SPRITE_SIZE + 8)

    self.leftRenderer:drawChar()
    self.rightRenderer:drawChar()
end

function MenuScene:update(dt)
    self.torrentAnimation:update(dt)
    self.fireballAnimation:update(dt)

    self.leftRenderer:updateCharAnimations(dt)
    self.rightRenderer:updateCharAnimations(dt)
end

function MenuScene:handleInput(userInput)
    if userInput == "play" then
        self.ctx.sceneManager:changeScene(SceneId.CharacterSelect)
    elseif userInput == "browse" then
        self.ctx.sceneManager:changeScene(SceneId.CardBrowse)
    elseif userInput == "quit" then
        love.event.quit()
    end
end
