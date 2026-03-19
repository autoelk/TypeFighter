Context = {}
Context.__index = Context

function Context:new()
    local context = {
        -- Managers are initialized first; `sceneManager` is initialized last
        -- because it needs the context reference.
        characterManager = CharacterManager:new(),
        resourceManager = ResourceManager:new(),
        runState = RunState:new(),

        fonts = {},
        assets = {},

        ui = {
            input = "",
            messageLeft = "",
            messageRight = "",
        }
    }

    -- cardManager needs `ctx` for creating cards with animations/fonts.
    context.cardManager = CardManager:new(context)

    context.sceneManager = SceneManager:new(context)
    return setmetatable(context, self)
end