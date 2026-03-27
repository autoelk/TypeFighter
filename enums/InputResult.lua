local InputResult = {
    Unknown = {},
    DrawSuccess = {},
    DrawFail = {},
    CardSelected = {},
    IncantationMismatch = {},
    IncantationCancelled = {},
    CastCard = require "enums.CastResult",
}

return setmetatable(InputResult, {
    __newindex = function()
        error("InputResult is read-only")
    end,
    __metatable = false,
})
