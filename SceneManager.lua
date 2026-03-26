local utf8 = require("utf8")

-- Manages different game scenes and transitions between them
SceneManager = {}
SceneManager.__index = SceneManager

function SceneManager:new(ctx)
    return setmetatable({
        scenes = {},
        sceneStack = {}, -- stack to manage overlay scenes
        paused = false,  -- if paused, only update the top scene
        ctx = ctx
    }, self)
end

function SceneManager:addScene(scene)
    self.scenes[scene.name] = scene
    scene.sceneManager = self
end

-- Change to a new scene, clearing the scene stack
function SceneManager:changeScene(sceneId)
    while #self.sceneStack > 0 do
        self:popScene()
    end
    self:pushScene(sceneId)
end

function SceneManager:pushScene(sceneId)
    local scene = self.scenes[sceneId]
    if not scene then
        error("Scene not found: " .. tostring(sceneId))
    end
    table.insert(self.sceneStack, scene)
    scene:enter()
end

function SceneManager:popScene()
    if #self.sceneStack == 0 then
        return
    end
    local scene = table.remove(self.sceneStack)
    scene:exit()
end

function SceneManager:getScene(name)
    return self.scenes[name]
end

function SceneManager:getCurrentScene()
    return self.sceneStack[#self.sceneStack]
end

function SceneManager:update(dt)
    if self.paused then
        self:getCurrentScene():update(dt)
    else
        for _, scene in ipairs(self.sceneStack) do
            scene:update(dt)
        end
    end
end

function SceneManager:draw()
    for _, scene in ipairs(self.sceneStack) do
        scene:draw()
    end
    
    local currentScene = self:getCurrentScene()
    currentScene:drawInputInterface()
end

function SceneManager:keypressed(key)
    local currentScene = self:getCurrentScene()
    local uiInput = self.ctx.ui.input
    if key == "backspace" and utf8.offset(uiInput, -1) then
        uiInput = string.sub(uiInput, 1, utf8.offset(uiInput, -1) - 1)
        self.ctx.ui.input = uiInput
        currentScene:updateSuggestedCommand()
        return
    end

    if key == "return" then
        local userInput = uiInput
        if currentScene.suggestedCommand and currentScene.suggestedCommandAutocomplete then
            userInput = currentScene.suggestedCommand
        end
        userInput = userInput:match("^%s*(.-)%s*$")
        self.ctx.ui.input = "" -- clear user input field
        currentScene:updateSuggestedCommand()
        currentScene:handleInput(userInput)
        return
    end
    currentScene:keypressed(key)
end

function SceneManager:textinput(t)
    self.ctx.ui.input = self.ctx.ui.input .. t
    self.ctx.ui.messageLeft = "" -- Clear message when user starts typing
    self:getCurrentScene():textinput(t)
end

function SceneManager:wheelmoved(x, y)
    self:getCurrentScene():wheelmoved(x, y)
end

function SceneManager:pause(val)
    self.paused = val
end
