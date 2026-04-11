require "cards.BaseCard"
require "spells.wizard.PortalSpell"

PortalCard = {}
setmetatable(PortalCard, {__index = BaseCard})
PortalCard.__index = PortalCard

function PortalCard:new(ctx, x, y)
    local card = BaseCard:new(ctx, x, y)
    card.name = "portal"
    card.incantationLength = 10
    card:setCharacter("wizard")
    card.anim = ctx.resourceManager:newAnimation("card_" .. card.name)

    card.SpellClass = PortalSpell
    card.spellData = { damage = 40 }
    return setmetatable(card, self)
end

function PortalCard:getDescription()
    return "deal " .. self.spellData.damage .. " damage."
end
