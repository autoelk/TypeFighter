local CastResult = {
    Success = {},
    CardNotInHand = {},
    InsufficientMana = {},
    InsufficientHealth = {},
    CannotCast = {}
}

return setmetatable(CastResult, {
    __newindex = function()
        error("CastResult is read-only")
    end,
    __metatable = false,
})
