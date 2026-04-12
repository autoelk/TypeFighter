require "cards.BaseCard"
require "spells.wizard.HealSpell"

HealCard = {}
setmetatable(HealCard, {__index = BaseCard})
HealCard.__index = HealCard

function HealCard:new(ctx, x, y)
    local card = BaseCard:new(ctx, x, y)
    card.name = "heal"
    card.incantationLength = 2
    card.anim = ctx.resourceManager:newAnimation("card_heal", "loop")

    card.SpellClass = HealSpell
    card.spellData = { healAmount = 10 }
    return setmetatable(card, self)
end

function HealCard:getDescription()
    return "gain " .. self.spellData.healAmount .. " health."
end
