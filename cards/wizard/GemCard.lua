require "cards.BaseCard"
require "spells.wizard.GemSpell"
local Keyword = require "enums.Keyword"

GemCard = {}
setmetatable(GemCard, {__index = BaseCard})
GemCard.__index = GemCard

function GemCard:new(ctx, x, y)
    local card = BaseCard:new(ctx, x, y)
    card.name = "gem"
    card.incantationLength = 2
    card:setCharacter("wizard")
    card.anim = ctx.resourceManager:newAnimation("card_" .. card.name, "loop")

    card.SpellClass = GemSpell
    card.spellData = {
        focusAmount = 5
    }
    card.keywords = { Keyword.Focus }
    return setmetatable(card, self)
end

function GemCard:getDescription()
    return "gain " .. self.spellData.focusAmount .. " focus."
end