-- Manages different game scenes and transitions between them
SceneManager = {}
SceneManager.__index = SceneManager

function SceneManager:new()
    return setmetatable({
        scenes = {},
        sceneStack = {} -- stack to manage overlay scenes
    }, self)
end

function SceneManager:addScene(scene)
    self.scenes[scene.name] = scene
    scene.sceneManager = self
end

-- Change to a new scene, clearing the scene stack
function SceneManager:changeScene(sceneName)
    while #self.sceneStack > 0 do
        self:popScene()
    end
    self:pushScene(sceneName)
end

function SceneManager:pushScene(sceneName)
    local scene = self.scenes[sceneName]
    if not scene then
        error("Scene not found: " .. tostring(sceneName))
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
    -- for now, we only update the top scene in the stack
    self:getCurrentScene():update(dt)
end

function SceneManager:draw()
    for _, scene in ipairs(self.sceneStack) do
        scene:draw()
    end
end

function SceneManager:keypressed(key)
    self:getCurrentScene():keypressed(key)
end

function SceneManager:wheelmoved(x, y)
    self:getCurrentScene():wheelmoved(x, y)
end
