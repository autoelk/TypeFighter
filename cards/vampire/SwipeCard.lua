require "cards.BaseCard"
require "spells.vampire.SwipeSpell"

SwipeCard = {}
setmetatable(SwipeCard, {__index = BaseCard})
SwipeCard.__index = SwipeCard

function SwipeCard:new(ctx, x, y)
    local card = BaseCard:new(ctx, x, y)
    card.name = "swipe"
    card.incantationLength = 1
    card.anim = ctx.resourceManager:newAnimation("card_" .. card.name, "loop")

    card.SpellClass = SwipeSpell
    card.spellData = {
        damage = 5
    }
    return setmetatable(card, self)
end

function SwipeCard:getDescription()
    return "deal " .. self.spellData.damage .. " damage."
end