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
    scene.controlsHint = "[p]lay game [b]rowse cards [q]uit"

    -- Load characters for display
    scene.leftRenderer = PlayerRenderer:new(ctx, BasePlayer:new(ctx, ctx.characterManager:createCharacter("wizard")))
    scene.leftRenderer.x = 320
    scene.leftRenderer.mirror = false

    scene.rightRenderer = PlayerRenderer:new(ctx, BasePlayer:new(ctx, ctx.characterManager:createCharacter("wizard")))
    scene.rightRenderer.x = GAME_WIDTH - 320 - SPRITE_SIZE
    scene.rightRenderer.mirror = true
    scene.rightRenderer.tint = COLORS.RED

    -- Load spells for display
    local margin = 340
    scene.torrentAnimation = ctx.resourceManager:newAnimation("card_torrent")
    scene.torrentAnimation.x = margin
    scene.torrentAnimation.y = 180
    scene.torrentAnimation.rotation = 0

    scene.fireballAnimation = ctx.resourceManager:newAnimation("card_fireball")
    scene.fireballAnimation.x = GAME_WIDTH - margin
    scene.fireballAnimation.y = 180 + SPRITE_SIZE + 8
    scene.fireballAnimation.rotation = 180

    return scene
end

function MenuScene:enter()
    self.ctx.ui.input = ""
    self.ctx.ui.messageLeft = "type p to start"
    self.ctx.ui.messageRight = self.controlsHint
end

function MenuScene:draw()
    local fonts = self.ctx.fonts
    lg.setColor(COLORS.WHITE)
    lg.setFont(fonts.fontXL)
    lg.printf("typefighter", 0, 200, GAME_WIDTH, "center")
    lg.setFont(fonts.fontM)
    lg.printf("[p]lay game\n[b]rowse cards\n[q]uit", 0, 300, GAME_WIDTH, "center")

    -- Animation
    local margin = 320
    local torrentSpriteNum = math.min(math.max(1, self.torrentAnimation.currentFrame), #self.torrentAnimation.quads)
    local fireballSpriteNum = math.min(math.max(1, self.fireballAnimation.currentFrame), #self.fireballAnimation.quads)
    lg.draw(self.torrentAnimation.spriteSheet, self.torrentAnimation.quads[torrentSpriteNum], 
        self.torrentAnimation.x, self.torrentAnimation.y, math.rad(self.torrentAnimation.rotation), 
        self.torrentAnimation.scaleX, self.torrentAnimation.scaleY)
    lg.draw(self.fireballAnimation.spriteSheet, self.fireballAnimation.quads[fireballSpriteNum],
        self.fireballAnimation.x, self.fireballAnimation.y, math.rad(self.fireballAnimation.rotation),
        self.fireballAnimation.scaleX, self.fireballAnimation.scaleY)

    self.leftRenderer:drawChar()
    self.rightRenderer:drawChar()
end

function MenuScene:update(dt)
    -- Update animations
    self.torrentAnimation.accumulator = self.torrentAnimation.accumulator + dt
    while self.torrentAnimation.accumulator >= self.torrentAnimation.frameDuration do
        self.torrentAnimation.accumulator = self.torrentAnimation.accumulator - self.torrentAnimation.frameDuration
        self.torrentAnimation.currentFrame = self.torrentAnimation.currentFrame + 1

        if self.torrentAnimation.currentFrame > #self.torrentAnimation.quads then
            self.torrentAnimation.currentFrame = 1
        end
    end

    self.fireballAnimation.accumulator = self.fireballAnimation.accumulator + dt
    while self.fireballAnimation.accumulator >= self.fireballAnimation.frameDuration do
        self.fireballAnimation.accumulator = self.fireballAnimation.accumulator - self.fireballAnimation.frameDuration
        self.fireballAnimation.currentFrame = self.fireballAnimation.currentFrame + 1

        if self.fireballAnimation.currentFrame > #self.fireballAnimation.quads then
            self.fireballAnimation.currentFrame = 1
        end
    end

    self.leftRenderer:updateCharAnimations(dt)
    self.rightRenderer:updateCharAnimations(dt)
end

function MenuScene:handleInput(userInput)
    if userInput == "p" or userInput == "play game" then
        self.ctx.sceneManager:changeScene(SceneId.CharacterSelect)
    elseif userInput == "b" then
        self.ctx.sceneManager:changeScene(SceneId.CardBrowse)
    elseif userInput == "q" or userInput == "quit" then
        love.event.quit()
    end
end
