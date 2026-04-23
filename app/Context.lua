Context = {}
Context.__index = Context

function Context:new()
    local context = {
        -- Managers are initialized first; `sceneManager` is initialized last
        -- because it needs the context reference.
        characterManager = CharacterManager:new(),
        resourceManager = ResourceManager:new(),

        fonts = {},
        assets = {},

        ui = {
            input = "",
            messageLeft = "",
            messageRight = "",
        }
    }
    context.cardManager = CardManager:new(context)
    context.sceneManager = SceneManager:new(context)
    context.runState = RunState:new(context)

    return setmetatable(context, self)
end