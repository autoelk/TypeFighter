require "cards.BaseCard"
require "spells.wizard.BlessingSpell"

BlessingCard = {}
setmetatable(BlessingCard, {__index = BaseCard})
BlessingCard.__index = BlessingCard

function BlessingCard:new(ctx, x, y)
    local card = BaseCard:new(ctx, x, y)
    card.name = "blessing"
    card.incantationLength = 3
    card:setCharacter("wizard")
    card.anim = ctx.resourceManager:newAnimation("card_" .. card.name)

    card.SpellClass = BlessingSpell
    card.spellData = {
        regenAmount = 5,
    }
    return setmetatable(card, self)
end

function BlessingCard:getDescription()
    return "apply " .. self.spellData.regenAmount .. " stacks of health regeneration."
end
