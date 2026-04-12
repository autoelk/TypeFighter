require "cards.BaseCard"
require "spells.vampire.SiphonSpell"
local Keyword = require "enums.Keyword"

SiphonCard = {}
setmetatable(SiphonCard, {__index = BaseCard})
SiphonCard.__index = SiphonCard

function SiphonCard:new(ctx, x, y)
    local card = BaseCard:new(ctx, x, y)
    card.name = "siphon"
    card.incantationLength = 2
    card.anim = ctx.resourceManager:newAnimation("card_" .. card.name, "loop")

    card.SpellClass = SiphonSpell
    card.spellData = {}
    card.keywords = { Keyword.Bleed }
    return setmetatable(card, self)
end

function SiphonCard:getDescription()
    return "gain shield equal to stacks of bleed on the target."
end