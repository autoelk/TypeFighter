require "cards.BaseCard"
require "spells.vampire.BloodPactSpell"

BloodPactCard = {}
setmetatable(BloodPactCard, {__index = BaseCard})
BloodPactCard.__index = BloodPactCard

function BloodPactCard:new(ctx, x, y)
    local card = BaseCard:new(ctx, x, y)
    card.name = "bloodpact"
    card.incantationLength = 5
    card:setCharacter("vampire")
    card.anim = ctx.resourceManager:newAnimation("card_" .. card.name)

    card.SpellClass = BloodPactSpell
    card.spellData = {}
    return setmetatable(card, self)
end

function BloodPactCard:getDescription()
    return "whenever you deal damage to yourself, draw a card."
end