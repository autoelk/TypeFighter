local SceneId = {
    Menu = "menu",
    CardBrowse = "cardBrowse",
    CharacterSelect = "characterSelect",
    Game = "game",
    Pause = "pause",
    GameOver = "gameOver",
    Instructions = "instructions",
    StageEnd = "stageEnd",
}

return setmetatable(SceneId, {
    __newindex = function()
        error("SceneId is read-only")
    end,
    __metatable = false,
})

