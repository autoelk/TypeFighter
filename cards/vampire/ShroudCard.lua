require "cards.BaseCard"
require "spells.vampire.ShroudSpell"

ShroudCard = {}
setmetatable(ShroudCard, {__index = BaseCard})
ShroudCard.__index = ShroudCard

function ShroudCard:new(ctx, x, y)
    local card = BaseCard:new(ctx, x, y)
    card.name = "shroud"
    card.incantationLength = 1
    card:setCharacter("vampire")
    card.anim = ctx.resourceManager:newAnimation("vampireSpellPlaceholder", "loop")

    card.SpellClass = ShroudSpell
    card.spellData = {
        shieldAmount = 5
    }
    return setmetatable(card, self)
end

function ShroudCard:getDescription()
    return "gain " .. self.spellData.shieldAmount .. " shield."
end
