require "scenes.BaseScene"

-- Menu Scene
MenuScene = {}
setmetatable(MenuScene, {
    __index = BaseScene
})
MenuScene.__index = MenuScene

function MenuScene:new()
    local scene = BaseScene:new()
    scene.name = "menu"
    scene.controlsHint = "[p]lay game [b]rowse cards [q]uit"

    -- Load characters for display
    scene.leftController = BasePlayerController:new(BasePlayer:new(characterManager:createCharacter("wizard")))
    scene.rightController = BasePlayerController:new(BasePlayer:new(characterManager:createCharacter("wizard")))
    scene.leftController.x = 250
    scene.leftController.y = 375
    scene.leftController.mirror = false
    scene.rightController.x = GAME_WIDTH - 250 - SPRITE_SIZE
    scene.rightController.y = 375
    scene.rightController.mirror = true
    scene.rightController.tint = COLORS.RED

    -- Load spells for display
    scene.torrentAnimation = resourceManager:newAnimation("card_torrent")
    scene.fireballAnimation = resourceManager:newAnimation("card_fireball")

    local margin = 280
    scene.torrentAnimation.x = margin
    scene.torrentAnimation.y = 180
    scene.torrentAnimation.rotation = 0
    scene.fireballAnimation.x = GAME_WIDTH - margin
    scene.fireballAnimation.y = 345
    scene.fireballAnimation.rotation = 180
    return setmetatable(scene, self)
end

function MenuScene:enter()
    input = ""
    messageLeft = "type p to start"
    messageRight = self.controlsHint
end

function MenuScene:draw()
    lg.setColor(COLORS.WHITE)
    lg.setFont(fontXL)
    lg.printf("typefighter", 0, 200, GAME_WIDTH, "center")
    lg.setFont(fontM)
    lg.printf("[p]lay game\n[b]rowse cards\n[q]uit", 0, 300, GAME_WIDTH, "center")

    -- Animation
    local margin = 280
    local torrentSpriteNum = math.min(math.max(1, self.torrentAnimation.currentFrame), #self.torrentAnimation.quads)
    local fireballSpriteNum = math.min(math.max(1, self.fireballAnimation.currentFrame), #self.fireballAnimation.quads)
    lg.draw(self.torrentAnimation.spriteSheet, self.torrentAnimation.quads[torrentSpriteNum], self.torrentAnimation.x,
        self.torrentAnimation.y, math.rad(self.torrentAnimation.rotation), self.torrentAnimation.scaleX,
        self.torrentAnimation.scaleY)
    lg.draw(self.fireballAnimation.spriteSheet, self.fireballAnimation.quads[fireballSpriteNum],
        self.fireballAnimation.x, self.fireballAnimation.y, math.rad(self.fireballAnimation.rotation),
        self.fireballAnimation.scaleX, self.fireballAnimation.scaleY)

    self.leftController:drawChar()
    self.rightController:drawChar()
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

    self.leftController:updateCharAnimations(dt)
    self.rightController:updateCharAnimations(dt)
end

function MenuScene:handleInput(userInput)
    if userInput == "p" or userInput == "play game" then
        self.sceneManager:changeScene("characterSelect")
    elseif userInput == "b" then
        self.sceneManager:changeScene("cardBrowse")
    elseif userInput == "q" or userInput == "quit" then
        love.event.quit()
    end
end
