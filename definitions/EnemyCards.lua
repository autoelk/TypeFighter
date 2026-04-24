-- Enemy card definitions
require "spells.enemy.ShiftKeySpell"

local Keyword = require "enums.Keyword"

return {
    shiftKey = {
        character = "shiftKey",
        incantationLength = 5,
        spell = ShiftKeySpell,
        spellData = { stacks = 3 },
        keywords = { Keyword.Shifted },
        previewSprite = "wizardSpellPlaceholder",
        description = function(d)
            return "randomly capitalize " .. d.stacks .. " letters from each word in your next " .. d.stacks .. " incantations."
        end,
    },
}