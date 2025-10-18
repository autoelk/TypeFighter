-- Manages different game scenes and transitions between them
SceneManager = {}
SceneManager.__index = SceneManager

function SceneManager:new()
    return setmetatable({
        scenes = {},
        currentScene = nil,
        currentSceneName = nil,
        previousScene = nil
    }, self)
end

function SceneManager:addScene(name, scene)
    self.scenes[name] = scene
    scene.sceneManager = self
end

function SceneManager:changeScene(sceneName)
    if self.currentScene and self.currentScene.exit then
        self.currentScene:exit()
    end

    self.previousScene = self.currentScene
    self.currentScene = self.scenes[sceneName]
    self.currentSceneName = sceneName

    if self.currentScene and self.currentScene.enter then
        self.currentScene:enter()
    end
end

function SceneManager:getCurrentScene()
    return self.currentScene
end

function SceneManager:getCurrentSceneName()
    return self.currentSceneName
end

function SceneManager:update(dt)
    if self.currentScene and self.currentScene.update then
        self.currentScene:update(dt)
    end
end

function SceneManager:draw()
    if self.currentScene and self.currentScene.draw then
        self.currentScene:draw()
    end
end

function SceneManager:keypressed(key)
    if self.currentScene and self.currentScene.keypressed then
        self.currentScene:keypressed(key)
    end
end

function SceneManager:wheelmoved(x, y)
    if self.currentScene and self.currentScene.wheelmoved then
        self.currentScene:wheelmoved(x, y)
    end
end
