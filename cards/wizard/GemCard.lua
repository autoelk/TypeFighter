require "cards.BaseCard"
require "spells.wizard.GemSpell"

GemCard = {}
setmetatable(GemCard, {
    __index = BaseCard
})
GemCard.__index = GemCard

function GemCard:new(ctx, x, y)
    local card = BaseCard:new(ctx, x, y)
    card.name = "gem"
    card.incantationLength = 2
    card:setCharacter("wizard")
    card.anim = ctx.resourceManager:newAnimation("card_" .. card.name)

    card.SpellClass = GemSpell
    card.spellData = {
        focusAmount = 1
    }
    setmetatable(card, self)
    return card
end

function GemCard:getDescription()
    return "gain " .. self.spellData.focusAmount .. " focus."
end