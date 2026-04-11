require "cards.BaseCard"
require "spells.vampire.BloodPactSpell"
local Keyword = require "enums.Keyword"

BloodPactCard = {}
setmetatable(BloodPactCard, {__index = BaseCard})
BloodPactCard.__index = BloodPactCard

function BloodPactCard:new(ctx, x, y)
    local card = BaseCard:new(ctx, x, y)
    card.name = "bloodpact"
    card.incantationLength = 5
    card:setCharacter("vampire")
    card.anim = ctx.resourceManager:newAnimation("vampireSpellPlaceholder")

    card.SpellClass = BloodPactSpell
    card.spellData = {}
    card.keywords = { Keyword.Sacrifice, Keyword.Consume }
    return setmetatable(card, self)
end

function BloodPactCard:getDescription()
    return "whenever you sacrifice, draw a card. consume."
end