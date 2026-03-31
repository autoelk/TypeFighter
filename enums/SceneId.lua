local SceneId = {
    Menu = "menu",
    CardBrowse = "cardBrowse",
    CharacterSelect = "characterSelect",
    Battle = "battle",
    Pause = "pause",
    GameOver = "gameOver",
    Instructions = "instructions",
    BattleEnd = "battleEnd",
}

return setmetatable(SceneId, {
    __newindex = function()
        error("SceneId is read-only")
    end,
    __metatable = false,
})

