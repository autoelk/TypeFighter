require "cards.BaseCard"
require "spells.wizard.BoltSpell"

BoltCard = {}
setmetatable(BoltCard, {
    __index = BaseCard
})
BoltCard.__index = BoltCard

function BoltCard:new(ctx, x, y)
    local card = BaseCard:new(ctx, x, y)
    card.name = "bolt"
    card.incantationLength = 1
    card:setCharacter("wizard")
    card.anim = ctx.resourceManager:newAnimation("card_" .. card.name)

    card.SpellClass = BoltSpell
    card.spellData = {
        damage = 5
    }
    setmetatable(card, self)
    return card
end

function BoltCard:getDescription()
    return "deal " .. self.spellData.damage .. " damage."
end
