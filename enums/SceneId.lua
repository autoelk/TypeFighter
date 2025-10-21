local SceneId = {
    Menu = {},
    CardBrowse = {},
    Instructions = {},
    CardSelect = {},
    Game = {},
    Pause = {},
    GameOver = {},
}

return setmetatable(SceneId, {
    __newindex = function()
        error("SceneId is read-only")
    end,
    __metatable = false,
})
