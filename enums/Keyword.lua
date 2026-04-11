local Keyword = {
    Consume = "consume",
    Bleed = "bleed",
    Sacrifice = "sacrifice",
    Focus = "focus",
}

Keyword.descriptions = {
    [Keyword.Consume] = "remove card from battle after use.",
    [Keyword.Bleed] = "when player casts a card, lose x health.",
    [Keyword.Sacrifice] = "lose x health",
    [Keyword.Focus] = "remove x letters from each word in incantations.",
}

return setmetatable(Keyword, {
    __newindex = function()
        error("Keyword is read-only")
    end,
    __metatable = false,
})