require "cards.BaseCard"
require "spells.vampire.LacerateSpell"
local Keyword = require "enums.Keyword"

LacerateCard = {}
setmetatable(LacerateCard, {__index = BaseCard})
LacerateCard.__index = LacerateCard

function LacerateCard:new(ctx, x, y)
    local card = BaseCard:new(ctx, x, y)
    card.name = "lacerate"
    card.incantationLength = 2
    card:setCharacter("vampire")
    card.anim = ctx.resourceManager:newAnimation("card_" .. card.name, "loop")

    card.SpellClass = LacerateSpell
    card.spellData = { 
        bleedAmount = 5,
    }
    card.keywords = { Keyword.Bleed }
    return setmetatable(card, self)
end

function LacerateCard:getDescription()
    return "apply " .. self.spellData.bleedAmount .. " stacks of bleed."
end
