local Keyword = {
    Consume = "consume",
    Bleed = "bleed",
    Sacrifice = "sacrifice",
    Focus = "focus",
    Shifted = "shifted",
}

Keyword.descriptions = {
    [Keyword.Consume] = "remove card from battle after use.",
    [Keyword.Bleed] = "when player casts a card, lose x health.",
    [Keyword.Sacrifice] = "lose x health",
    [Keyword.Focus] = "add/remove x random letters from each word in your next x incantations.",
    [Keyword.Shifted] = "capitalize the first x letters in your next x incantations.",
}

return setmetatable(Keyword, {
    __newindex = function()
        error("Keyword is read-only")
    end,
    __metatable = false,
})